#!/usr/bin/env bash

# Log ingestion agent install procedure:
# https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-config_agent_os_cluster

# Monitoring agent install procedure:
# https://cloud.ibm.com/docs/monitoring?topic=monitoring-openshift_cluster
# https://cloud.ibm.com/docs/monitoring?topic=monitoring-agent-deploy-openshift-helm
# https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started

CLUSTER_NAME="${1:?CLUSTER_NAME is required}"
REGION="${2:?REGION is required}"
LOG_INGEST_KEY="${3:?LOG_INGEST_KEY is required}"
SYSDIG_ACCESS_KEY="${4?SYSDIG_ACCESS_KEY is required}"

set -e
# set -x

ibmcloud ks cluster config -c "${CLUSTER_NAME}" --admin

# install log agent daemon set

[[ -n "$(oc get project ibm-observes --ignore-not-found 2>/dev/null)" ]] || {
  oc adm new-project --node-selector='' ibm-observe
  oc create serviceaccount logdna-agent -n ibm-observe
  oc adm policy add-scc-to-user privileged system:serviceaccount:ibm-observe:logdna-agent
  oc create secret generic logdna-agent-key --from-literal=logdna-agent-key="${LOG_INGEST_KEY}" -n ibm-observe
}
oc apply -f "https://assets.${REGION}.logging.cloud.ibm.com/clients/logdna-agent/3/agent-resources-openshift.yaml"

# install monitor agent daemon set
helm repo add sysdig https://charts.sysdig.com
helm repo update
helm upgrade --install -n ibm-observe sysdig-agent sysdig/sysdig-deploy -f monitor-agent-values.yaml \
  --set global.clusterConfig.name="${CLUSTER_NAME}" \
  --set global.sysdig.accessKey="${SYSDIG_ACCESS_KEY}" \
  --set agent.collectorSettings.collectorHost="ingest.${REGION}.monitoring.cloud.ibm.com" \
  --set nodeAnalyzer.nodeAnalyzer.apiEndpoint="${REGION}.monitoring.cloud.ibm.com"
