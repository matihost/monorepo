#!/usr/bin/env bash

CLUSTER_RG="${1:?CLUSTER_RG is required}"
CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
API_URL="${3:?CLUSTER_NAME is required}"

REGION="${4:?REGION is required}"
OIDC="${5:?OIDC is required}"
NAMESPACES="${6:?NAMESPACES is required}"
LOG_WORKSPACE_ID="${7:?LOG_WORKSPACE_ID is required}"
LOG_WORKSPACE_SHARED_KEY="${8:?LOG_WORKSPACE_SHARED_KEY is required}"
TENANT_ID="${9:?TENANT_ID is required}"
AZURE_MONITOR_URL="${10:?TENANT_ID is required}"
MP_CLIENT_ID="${11:?MP_CLIENT_ID is required}"
MP_CLIENT_SECRET="${12:?MP_CLIENT_SECRET is required}"
MP_DCR_ID="${13:?MP_DCR_ID is required}"
SUBSCRIPTION_ID="${14:?SUBSCRIPTION_ID is required}"
BACKUP_CLIENT_ID="${15:?BACKUP_CLIENT_ID is required}"
BACKUP_CLIENT_SECRET="${16:?BACKUP_CLIENT_SECRET is required}"
BACKUP_STORAGE_ACCOUNT="${17:?BACKUP_STORAGE_ACCOUNT is required}"
BACKUP_CONTAINER_NAME="${18:?BACKUP_CONTAINER_NAME is required}"
PAGERDUTY_ROUTING_KEY="${19:-}"

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
    --set tenant_id="${TENANT_ID}" \
    --set azure_monitor.ingestion_url="${AZURE_MONITOR_URL}" \
    --set azure_monitor.client_id="${MP_CLIENT_ID}" \
    --set azure_monitor.client_secret="${MP_CLIENT_SECRET}" \
    --set azure_monitor.dcr_id="${MP_DCR_ID}" \
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
  # enableUserWorkloads in cluster-monitoring-config/openshift-monitoring config map part of cluster-config-chart
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
  [[ -n "$(oc get obsclf -n openshift-logging --no-headers --ignore-not-found 2>/dev/null)" ]] || {
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
  #  - name: azure-monitor-infra
  #    type: azureMonitor
  #    azureMonitor:
  #      authentication:
  #        sharedKey:
  #          key: shared_key
  #          secretName: azure-monitor-shared-key
  #      customerId: $LOG_WORKSPACE_ID
  #      logType: aro_${CLUSTER_NAME//-/_}_infrastructure_logs
   pipelines:
   - name: app-pipeline
     inputRefs:
     - application
     outputRefs:
     - azure-monitor-app
  #  - name: infra-pipeline
  #    inputRefs:
  #    - infrastructure
  #    outputRefs:
  #    - azure-monitor-infra
   serviceAccount:
      name: default
EOF
}

install-logging-operator() {
  [[ -n "$(oc get project openshift-logging --no-headers --ignore-not-found 2>/dev/null)" ]] || {
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
  channel: stable-6.4
  name: cluster-logging
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  }
  wait_for_resource ClusterLogForwarder
}

wait_for_resource() {
  local resource="$1" timeout=300 interval=5 elapsed=0
  while true; do
    [[ "$(oc api-resources | grep -c "$resource")" -gt 0 ]] && return 0
    ((elapsed >= timeout)) && {
      echo "Timeout waiting for $resource"
      exit 1
    }
    sleep "$interval"
    ((elapsed += interval))
  done
}

# ARO backup with Velero/OADP
# https://cloud.redhat.com/experts/aro/backup-restore/
configure-backup() {
  [[ -n "$(oc get project openshift-adp --no-headers --ignore-not-found 2>/dev/null)" ]] || {
    oc adm new-project --node-selector='' openshift-adp
    oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: openshift-adp
  namespace: openshift-adp
spec:
  targetNamespaces:
    - openshift-adp
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: redhat-oadp-operator
  namespace: openshift-adp
spec:
  channel: stable-1.4
  name: redhat-oadp-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
  }
  wait_for_resource BackupStorageLocation
  oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cloud-credentials
  namespace: openshift-adp
type: Opaque
stringData:
  cloud: |
    AZURE_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
    AZURE_TENANT_ID=${TENANT_ID}
    AZURE_CLIENT_ID=${BACKUP_CLIENT_ID}
    AZURE_CLIENT_SECRET=${BACKUP_CLIENT_SECRET}
EOF

  export BACKUP_RG="${CLUSTER_RG}"
  oc apply -f - <<EOF
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: azure-dpa
  namespace: openshift-adp
spec:
  backupLocations:
    - name: azure-backup
      velero:
        provider: azure
        default: true
        objectStorage:
          bucket: ${BACKUP_CONTAINER_NAME}
          prefix: backups
        config:
          resourceGroup: ${BACKUP_RG}
          storageAccount: ${BACKUP_STORAGE_ACCOUNT}
          subscriptionId: ${SUBSCRIPTION_ID}
          useAAD: 'true'
        credential:
          name: cloud-credentials
          key: cloud
  snapshotLocations:
    - name: azure-snapshot
      velero:
        provider: azure
        config:
          resourceGroup: ${CLUSTER_RG}
          subscriptionId: ${SUBSCRIPTION_ID}
          apiTimeout: 2m0s
        credential:
          name: cloud-credentials
          key: cloud
  configuration:
    velero:
      defaultPlugins:
        - openshift
        - csi
        - azure
      defaultSnapshotMoveData: true
    nodeAgent:
      enable: true
      uploaderType: kopia
EOF

  oc label volumesnapshotclass csi-azuredisk-vsc velero.io/csi-volumesnapshot-class=true

  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"

    cat <<EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ${NS}-daily-backup
  namespace: openshift-adp
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM, so RPO is 24h
  template:
    includedNamespaces:
      - ${NS}
    excludedResources:
      - imagestreams.image.openshift.io
      - builds.build.openshift.io
      - buildconfigs.build.openshift.io
      - pods
    includeClusterResources: false
    snapshotVolumes: false
    defaultVolumesToFsBackup: true
    ttl: 168h0m0s  # 7 days retention
EOF
  done

  NAMESPACES_NAMES="$(echo "${NAMESPACES}" | jq -cr '[.[].name]')"
  cat <<EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: cluster-daily-backup
  namespace: openshift-adp
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM, RPO = 24h
  template:
    includedNamespaces:
      - "*"  # all namespaces
    excludedNamespaces: ${NAMESPACES_NAMES}
    includeClusterResources: true
    excludedResources:
      - imagestreams.image.openshift.io
    snapshotVolumes: false
    defaultVolumesToFsBackup: false
    ttl: 168h                          # 7 days retention
EOF

  cat <<EOF | oc apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app: oadp-service-monitor
  name: oadp-service-monitor
  namespace: openshift-adp
spec:
  endpoints:
  - interval: 30s
    path: /metrics
    targetPort: 8085
    scheme: http
  selector:
    matchLabels:
      app.kubernetes.io/name: "velero"
EOF

  cat <<EOF | oc apply -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: backup-rules
  namespace: openshift-user-workload-monitoring
spec:
  groups:
  - name: backup.rules
    rules:
    - alert: OADPBackupFailing
      annotations:
        description: 'OADP had {{\$value | humanize}} backup failures over the last 24 hours.'
        summary: OADP has issues creating backups
      expr: |
        increase(velero_backup_failure_total{job="openshift-adp-velero-metrics-svc"}[24h]) > 0
      for: 5m
      labels:
        severity: critical
        cluster: ${CLUSTER_NAME}
EOF
}

# Main
login-to-aro
ensure-cluster-config
configure-monitoring
configure-logging-forwarding-to-log-analytics-workspace
configure-backup
configure-namespaces

# TODO for monitoring
# https://github.com/SenWangMSFT/aro-logging-and-metrics-forwarding?tab=readme-ov-file#application-logs-forwarding-to-azure-log-analytics
# https://cloud.redhat.com/experts/o11y/openshift-coo-azuremonitor/

# TODO install ARO ExternalDNS

# TODO configure
# https://learn.microsoft.com/en-us/azure/openshift/configure-azure-ad-cli

# TODO configure Service Mesh

# TODO configure
#  https://learn.microsoft.com/en-us/azure/openshift/howto-secure-openshift-with-front-door

# Azure monitoring:
# https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=cli
