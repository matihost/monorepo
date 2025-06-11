#!/usr/bin/env bash

# Environment variables dependencies:
#
# DEPLOYMENT - what are deployment/namespaces and desired replica after scaling up: name;namespace;number
# During scalling down these deployments are scaled to 0
DEPLOYMENTS="echoserver;learning;1"

# CRON_NS - namespaces where CronJobs needs to be suspended before scalling down. They are unsuspended during scaling up process
CRON_NS="learning
test"

# VM_SIZE_DOWN and VM_SIZE_UP - desired sizes of VMs for scalling down and up processes.
# Number of worker nodes are assumed hardcoded, which is 1 node per zone (3 in total)
VM_SIZE_DOWN="Standard_D4s_v5"
VM_SIZE_UP="Standard_D8s_v5"

# MODE - whether script is perfoming scaling down or up
MODE="${1:?MODE is mandatory - either down or up}"

function scale_deployments() {
  DEPLOYMENTS="${1:?Deployments in format name;namespace;number delimited by end of the line}"

  FORCE_REPLICAS="${2:-1}"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue # Skip empty lines

    IFS=';' read -r deployment namespace replicas <<<"$line"

    if [ "${FORCE_REPLICAS}" -ne -1 ]; then
      replicas="${FORCE_REPLICAS}"
    fi
    echo "Scaling deployment '$deployment' in namespace '$namespace' to $replicas replicas"
    oc scale deployment "$deployment" -n "$namespace" --replicas="$replicas"

  done <<<"$DEPLOYMENTS"
}

function suspend_cronjobs() {
  NS="${1:?Namespace in format of name delimited by end of the line}"
  SUSPEND_MODE="${2:-true}"

  for namespace in $NS; do
    cronjobs=$(oc get cronjobs -n "$namespace" --no-headers -o custom-columns=":metadata.name")

    for cj in $cronjobs; do
      echo "Set CronJob: $namespace/$cj suspend mode to: ${SUSPEND_MODE}"
      oc patch cronjob "$cj" -n "$namespace" -p "{\"spec\" : {\"suspend\" : ${SUSPEND_MODE} }}"
    done
  done
}

function delete_active_jobs() {
  NS="${1:?Namespace list (newline-delimited)}"

  for namespace in $NS; do
    echo "Deleting non-Completed Jobs in namespace: $namespace"
    jobs=$(oc get jobs -n "$namespace" --no-headers -o custom-columns=NAME:.metadata.name)

    for job in $jobs; do
      complete_status=$(oc get job "$job" -n "$namespace" -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}')
      if [[ "$complete_status" != "True" ]]; then
        echo "Deleting job: $namespace/$job"
        oc delete job "$job" -n "$namespace" --force --grace-period=0 --ignore-not-found
      fi
    done
  done
}

# shellcheck disable=SC2120
function wait_for_ready_workers() {
  local MAX_WAIT=${1:-1800}  # default: 30 minutes
  local TARGET_READY=${2:-3} # default: 3 ready nodes
  local INTERVAL=10
  local ELAPSED=0

  echo "Waiting up to $((MAX_WAIT / 60)) minutes for $TARGET_READY Ready worker nodes..."

  while true; do
    local READY_NODES
    READY_NODES=$(oc get nodes --selector='node-role.kubernetes.io/worker' --no-headers |
      awk '$2 == "Ready" { count++ } END { print count+0 }')
    echo "Ready worker nodes: $READY_NODES / $TARGET_READY"

    if [[ $READY_NODES -ge $TARGET_READY ]]; then
      echo "OK - Desired number of worker nodes are Ready."
      return 0
    fi

    if [[ $ELAPSED -ge $MAX_WAIT ]]; then
      echo "ALERT: Timeout reached. Only $READY_NODES / $TARGET_READY worker nodes are Ready after $((MAX_WAIT / 60)) minutes."
      # TODO alert
      return 1
    fi

    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
  done
}

function scale_machinesets() {
  VM_SIZE="${1:?VM size is mandatory}"
  MACHINE_SETS=$(oc get machineset -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=worker -o jsonpath='{.items[*].metadata.name}')
  OLD_MACHINES="$(oc get machines -n openshift-machine-api -l machine.openshift.io/cluster-api-machine-role=worker -o custom-columns=NAME:.metadata.name --no-headers)"

  for MS in $MACHINE_SETS; do
    echo "Patching MachineSet $MS to change instance type to ${VM_SIZE}..."
    oc patch machineset "${MS}" -n openshift-machine-api --type='merge' -p "{\"spec\":{\"template\":{\"spec\":{\"providerSpec\":{\"value\":{\"vmSize\": \"${VM_SIZE}\"}}}}}}"
  done

  for MS in $OLD_MACHINES; do
    NODE_NAME=$(oc get machine "${MS}" -n openshift-machine-api -o jsonpath='{.status.nodeRef.name}' 2>/dev/null)

    echo "Deleting Machine ${MS}..."
    oc delete machine "${MS}" -n openshift-machine-api --wait=false
    sleep 60
    wait_for_ready_workers
    wait_for_machine_deletion "${MS}"

    # Check if the machine is still present
    echo "Verifying if Machine ${MS} has been deleted..."
    if oc get machine "${MS}" -n openshift-machine-api &>/dev/null; then
      echo "Machine ${MS} still exists. Deleting forcefully..."
      echo "Force deleting machine ${MS} and node ${NODE_NAME}..."
      oc delete node "${NODE_NAME}" --grace-period=0 --force
      oc delete machine "${MS}" -n openshift-machine-api --grace-period=0 --force
    else
      echo "Machine ${MS} successfully deleted."
    fi
  done
  return 0
}

function wait_for_machine_deletion() {
  local MACHINE_NAME="${1:?Machine name is required}"
  local NAMESPACE="${2:-openshift-machine-api}"
  local TIMEOUT_SECONDS="${3:-600}" # Default: 10 minutes
  local INTERVAL=10
  local ELAPSED=0

  echo "Waiting for machine '$MACHINE_NAME' to be deleted from namespace '$NAMESPACE'..."

  while ((ELAPSED < TIMEOUT_SECONDS)); do
    if ! kubectl get machine "$MACHINE_NAME" -n "$NAMESPACE" &>/dev/null; then
      echo "Machine '$MACHINE_NAME' deleted."
      return 0
    fi

    echo "Machine '$MACHINE_NAME' still exists... ($ELAPSED/${TIMEOUT_SECONDS}s)"
    sleep "$INTERVAL"
    ((ELAPSED += INTERVAL))
  done

  echo "Timeout: Machine '$MACHINE_NAME' was not deleted within $((TIMEOUT_SECONDS / 60)) minutes."
}

function delete_jobs_with_pending_pods_clusterwide() {
  echo "Scanning for Jobs with Pending pods..."
  namespaces=$(oc get jobs --all-namespaces --no-headers -o custom-columns=":metadata.namespace")

  for ns in $namespaces; do
    jobs=$(oc get jobs -n "$ns" --no-headers -o custom-columns=":metadata.name")
    for job in $jobs; do
      pods=$(oc get pods -n "$ns" -l job-name="$job" --no-headers -o custom-columns=":metadata.name,:status.phase")
      while read -r pod_name pod_status; do
        if [[ "$pod_status" == "Pending" ]]; then
          echo "Deleting job '$job' in namespace '$ns' due to Pending pod '$pod_name'"
          oc delete job "$job" -n "$ns" --force --grace-period=0 --ignore-not-found
          break # Skip further pods for this job
        fi
      done <<<"$pods"
    done
  done
}

function wait_for_deployments_ready() {
  local DEPLOYMENTS="$1" # Format: name;namespace;replicas (newline-delimited)
  local TIMEOUT_MINUTES="${2:-30}"
  local TIMEOUT_SECONDS=$((TIMEOUT_MINUTES * 60))
  local INTERVAL=10
  local ELAPSED=0

  echo "Waiting up to $TIMEOUT_MINUTES minutes for all deployments to be ready..."

  while ((ELAPSED < TIMEOUT_SECONDS)); do
    all_ready=true

    while read -r line; do
      [[ -z "$line" ]] && continue
      IFS=';' read -r deploy ns expected <<<"$line"

      ready=$(oc get deploy "$deploy" -n "$ns" -o jsonpath="{.status.readyReplicas}")
      ready=${ready:-0} # default to 0 if empty

      echo "Deployment status $deploy in $ns: $ready / $expected ready"

      if ((ready < expected)); then
        all_ready=false
      fi
    done <<<"$DEPLOYMENTS"

    if $all_ready; then
      echo "All deployments are ready."
      return 0
    fi

    sleep "$INTERVAL"
    ((ELAPSED += INTERVAL))
  done

  echo "ALERT: Timeout after $TIMEOUT_MINUTES minutes. Not all deployments are ready."
  # TODO alert
  return 1
}

function main() {
  if [[ $MODE == "down" ]]; then
    suspend_cronjobs "${CRON_NS}" true
    echo "Wait for ongoing jobs to finish"
    sleep 60
    delete_active_jobs "${CRON_NS}"
    scale_deployments "${DEPLOYMENTS}" 0
    scale_machinesets "${VM_SIZE_DOWN}"
  elif [[ $MODE == "up" ]]; then
    delete_jobs_with_pending_pods_clusterwide
    delete_active_jobs "${CRON_NS}"
    scale_machinesets "${VM_SIZE_UP}"
    scale_deployments "${DEPLOYMENTS}"
    suspend_cronjobs "${CRON_NS}" false
    wait_for_deployments_ready "${DEPLOYMENTS}"
  else
    echo "ALERT: Mode can be either 'down' or 'up'. Exiting"
    return 1
  fi
}

# Main

main
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
  echo "ALERT: Scaling script with mode: '$MODE' failed. See previous log for details"
  # TODO alert
fi
