#!/usr/bin/env bash

CLUSTER_RG="${1:?CLUSTER_RG is required}"
CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
API_URL="${3:?CLUSTER_NAME is required}"

REGION="${4:?REGION is required}"
OIDC="${5:?OIDC is required}"
NAMESPACES="${6:?NAMESPACES is required}"
LOG_WORKSPACE_ID="${7:?LOG_WORKSPACE_ID is required}"
LOG_WORKSPACE_SHARED_KEY="${8:?LOG_WORKSPACE_SHARED_KEY is required}"
PAGERDUTY_ROUTING_KEY="${9:-}"

# set -e
set -x

DIRNAME="$(dirname "$0")"

function login-to-aro() {
  oc login --insecure-skip-tls-verify=true -u kubeadmin -p "$(az aro list-credentials --name "${CLUSTER_NAME}" --resource-group "${CLUSTER_RG}" 2>/dev/null | jq -r ".kubeadminPassword")" "${API_URL}"
}

function import_existing_object_to_helm() {
  oc annotate --overwrite "${1}" "${2}" meta.helm.sh/release-name="${3}"
  oc annotate --overwrite "${1}" "${2}" meta.helm.sh/release-namespace="${4}"
  oc label --overwrite "${1}" "${2}" app.kubernetes.io/managed-by=Helm
}

function import_existing_ns_object_to_helm() {
  oc annotate --overwrite "${1}" "${2}" -n "${3}" meta.helm.sh/release-name="${4}"
  oc annotate --overwrite "${1}" "${2}" -n "${3}" meta.helm.sh/release-namespace="${5}"
  kubectl label --overwrite "${1}" "${2}" -n "${3}" app.kubernetes.io/managed-by=Helm
}

function disable_default_storageclass() {
  oc patch storageclass managed-csi -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}

function ensure-authenticated-only-cannot-create-projects() {
  oc get clusterrolebinding.rbac self-provisioners 2>/dev/null >/dev/null && {
    oc annotate clusterrolebinding.rbac self-provisioners 'rbac.authorization.kubernetes.io/autoupdate=false' --overwrite
    oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated:oauth
  }
}

function ensure-cluster-config() {
  ensure-authenticated-only-cannot-create-projects
  disable_default_storageclass
  import_existing_object_to_helm oauths cluster cluster-config cluster-config

  # has to be with --force - otherwise imported resources to Helm - are not updated with Helm
  # https://github.com/helm/helm/issues/11040#issuecomment-1154702487
  helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
    --force \
    --set clusterName="${CLUSTER_NAME}" \
    --set region="${REGION}" \
    --set-json oidc="$(echo -n "${OIDC}" | jq -r)"
}

function configure-namespaces() {
  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"
    QUOTA="$(echo "${NAMESPACE}" | jq -r ".quota")"

    [ -n "$(kubectl get ns "${NS}" --no-headers --ignore-not-found)" ] || {
      oc new-project "${NS}"
    }
    helm upgrade --install "ns-${NS}-config" -n cluster-config --create-namespace "${DIRNAME}/namespace-config-chart" \
      --set namespace="${NS}" \
      --set-json quota="$(echo "${QUOTA}" | jq -r)"
  done
}

function configure-monitoring() {
  # Enable User Workload Monitoring (aka PrometheusRule objects in own namespaces)
  # https://cloud.redhat.com/experts/aro/user-workload-monitoring/
  # https://docs.redhat.com/en/documentation/openshift_container_platform/4.17/html/monitoring/configuring-user-workload-monitoring#enabling-monitoring-for-user-defined-projects_preparing-to-configure-the-monitoring-stack-uwm
  cat <<EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
EOF
  configure-pager-duty-receiver
}

# Configure Prometheus/Alert Manager in ARO to use PagerDuty as alert receiver
# https://www.pagerduty.com/docs/guides/prometheus-integration-guide/
function configure-pager-duty-receiver() {
  if [[ -n "${PAGERDUTY_ROUTING_KEY:-}" ]]; then
    RECEIVER_NAME="pagerduty"
    TMP_DIR=$(mktemp -d)
    ALERTMANAGER_FILE="${TMP_DIR}/alertmanager.yaml"

    # fetch and decode alertmanager.yaml from secret
    oc -n openshift-monitoring get secret alertmanager-main -o jsonpath='{.data.alertmanager\.yaml}' |
      base64 -d >"$ALERTMANAGER_FILE"

    cp "$ALERTMANAGER_FILE" "${ALERTMANAGER_FILE}.bak"

    # add PagerDuty receiver if missing
    # the format for summary of the alert visible in PagerDuty is part of description pagerduty_configs parameter
    # here is the default summary:
    # https://github.com/prometheus/alertmanager/blob/main/template/default.tmpl
    if ! yq -e ".receivers[] | select(.name == \"${RECEIVER_NAME}\")" "$ALERTMANAGER_FILE" >/dev/null 2>&1; then
      yq -i -y ".receivers += [{
        \"name\": \"${RECEIVER_NAME}\",
        \"pagerduty_configs\": [{
          \"routing_key\": \"${PAGERDUTY_ROUTING_KEY}\",
          \"description\": \"[${CLUSTER_NAME}] {{ .GroupLabels.SortedPairs.Values | join \\\" \\\" }} {{ if gt (len .CommonLabels) (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{ .Values | join \\\" \\\" }}{{ end }}){{ end }}\"
        }]
      }]" "$ALERTMANAGER_FILE"
    fi

    if ! yq -e ".route.routes[]? | select(.matchers[]? == \"severity = critical\" and .receiver == \"${RECEIVER_NAME}\")" "$ALERTMANAGER_FILE" >/dev/null 2>&1; then
      yq -i -y ".route.routes += [{
        \"matchers\": [\"severity = critical\"],
        \"receiver\": \"${RECEIVER_NAME}\"
      }]" "$ALERTMANAGER_FILE"
    fi

    ENCODED=$(base64 -w0 <"$ALERTMANAGER_FILE")
    oc -n openshift-monitoring patch secret alertmanager-main \
      --type='json' \
      -p="[{\"op\": \"replace\", \"path\": \"/data/alertmanager.yaml\", \"value\": \"${ENCODED}\"}]"

    # Rollout restart of Alertmanager StatefulSet to ensure new config is read
    oc -n openshift-monitoring rollout restart statefulset alertmanager-main
  fi
}

# https://cloud.redhat.com/experts/aro/clf-to-azure/
# https://access.redhat.com/solutions/7123336
# https://docs.okd.io/4.14/observability/logging/logging-6.0/log6x-clf.html#log6x-input-spec-filter-audit-infrastructure_logging-6x
configure-logging-forwarding-to-log-analytics-workspace() {
  install-logging-operator

  [[ -n "$(oc get clusterlogforwarder -n openshift-logging --no-headers --ignore-not-found 2>/dev/null)" ]] || {
    oc -n openshift-logging create secret generic azure-monitor-shared-key --from-literal=shared_key="${LOG_WORKSPACE_SHARED_KEY}"
    oc create clusterrolebinding collect-app-logs --clusterrole=collect-application-logs --serviceaccount openshift-logging:default
    oc create clusterrolebinding collect-infra-logs --clusterrole=collect-infrastructure-logs --serviceaccount openshift-logging:default
    oc create clusterrolebinding collect-audit-logs --clusterrole=collect-audit-logs --serviceaccount openshift-logging:default
  }
  cat <<EOF | oc apply -f -
apiVersion: observability.openshift.io/v1
kind: ClusterLogForwarder
metadata:
   name: instance
   namespace: openshift-logging
spec:
   outputs:
   - name: azure-monitor-app
     type: azureMonitor
     azureMonitor:
       authentication:
         sharedKey:
           key: shared_key
           secretName: azure-monitor-shared-key
       customerId: $LOG_WORKSPACE_ID
       logType: aro_${CLUSTER_NAME//-/_}_application_logs
   - name: azure-monitor-infra
     type: azureMonitor
     azureMonitor:
       authentication:
         sharedKey:
           key: shared_key
           secretName: azure-monitor-shared-key
       customerId: $LOG_WORKSPACE_ID
       logType: aro_${CLUSTER_NAME//-/_}_infrastructure_logs
   pipelines:
   - name: app-pipeline
     inputRefs:
     - application
     outputRefs:
     - azure-monitor-app
   - name: infra-pipeline
     inputRefs:
     - infrastructure
     outputRefs:
     - azure-monitor-infra
   serviceAccount:
      name: default
EOF
}

install-logging-operator() {
  [[ -n "$(oc get project openshift-logging--no-headers --ignore-not-found 2>/dev/null)" ]] || {
    oc adm new-project --node-selector='' openshift-logging
    oc label namespace openshift-logging openshift.io/cluster-monitoring="true" --overwrite
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-logging
  namespace: openshift-logging
spec:
  targetNamespaces:
    - openshift-logging
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: cluster-logging
  namespace: openshift-logging
spec:
  channel: stable-6.3
  name: cluster-logging
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  }

}

# Main
login-to-aro
ensure-cluster-config
configure-namespaces
configure-monitoring
configure-logging-forwarding-to-log-analytics-workspace

# TODO install ARO ExternalDNS

# TODO configure
# https://learn.microsoft.com/en-us/azure/openshift/configure-azure-ad-cli

# TODO configure Backup
# https://learn.microsoft.com/en-us/azure/openshift/howto-create-a-backup

# TODO configure Service Mesh

# TODO configure
#  https://learn.microsoft.com/en-us/azure/openshift/howto-secure-openshift-with-front-door

# Azure monitoring:
# https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli
