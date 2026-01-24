#!/usr/bin/env bash

ACCOUNT_ID="${1:?ACCOUNT_ID is required}"
CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
REGION="${3:?REGION is required}"
NAMESPACES="${4:?NAMESPACES is required}"
INSTALL_NGINX="${5:-false}"
DATADOG_API_KEY="${6:-}"
DATADOG_APP_KEY="${7:-}"

set -e
set -x

DIRNAME="$(dirname "$0")"

function login-to-eks() {
  # login to AWS - assuming running as IAM principal being registered via aws_eks_access_entry and aws_eks_access_policy_association
  aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"
}

function ensure-cluster-config() {
  helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
    --set clusterName="${CLUSTER_NAME}" \
    --set region="${REGION}"
}

function configure-namespaces() {
  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"
    QUOTA="$(echo "${NAMESPACE}" | jq -r ".quota")"

    IRSA_ROLE=""
    IRSA_POLICY="$(echo "${NAMESPACE}" | jq -r ".irsa_policy")"
    [[ -n "${IRSA_POLICY}" && "${IRSA_POLICY}" != "null" ]] && {
      IRSA_ROLE="${CLUSTER_NAME}-${NS}-irsa"
    }

    [ -n "$(kubectl get ns "${NS}" --no-headers --ignore-not-found)" ] || {
      kubectl create ns "${NS}"
    }
    helm upgrade --install "ns-${NS}-config" -n cluster-config --create-namespace "${DIRNAME}/namespace-config-chart" \
      --set namespace="${NS}" \
      --set aws.accountId="${ACCOUNT_ID}" \
      --set irsaRole="${IRSA_ROLE}" \
      --set-json quota="$(echo "${QUOTA}" | jq -r)"
  done
}

function ensure-nginx() {
  [ "${INSTALL_NGINX}" == "true" ] && {
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm upgrade --install ingress-nginx -n kube-system ingress-nginx/ingress-nginx -f "${DIRNAME}/nginx.yaml" \
      --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name="${CLUSTER_NAME}-nginx-ingress"
  }
}

function ensure-externaldns() {
  helm repo add external-dns https://kubernetes-sigs.github.io/external-dns
  helm repo update
  helm upgrade --install external-dns -n kube-system external-dns/external-dns -f "${DIRNAME}/external-dns.yaml" \
    --set env[0].name="AWS_DEFAULT_REGION" \
    --set env[0].value="${REGION}"
}

function ensure-datadog-agent() {
  # installing Datadog operator via Helm not via EKS addoon, as EKS addon requires manual Datadog subscription setup
  # (free but cannot be automated easily)
  [ -z "${DATADOG_API_KEY}" ] || [ -z "${DATADOG_APP_KEY}" ] || {
    helm repo add datadog https://helm.datadoghq.com
    helm upgrade --install datadog-operator -n datadog --create-namespace datadog/datadog-operator \
      --set apiKey="${DATADOG_API_KEY}" \
      --set appKey="${DATADOG_APP_KEY}" \
      --set clusterName="${CLUSTER_NAME}" \
      -f "${DIRNAME}/datadog.yaml"
    NAMESPACES_NAMES="$(echo "${NAMESPACES}" | jq -cr '[.[].name]')"
    kubectl apply -f - <<EOF
kind: "DatadogAgent"
apiVersion: "datadoghq.com/v2alpha1"
metadata:
  name: "datadog"
  namespace: "datadog"
spec:
  global:
    clusterName: "${CLUSTER_NAME}"
    site: "datadoghq.com"
    credentials:
      apiSecret:
        secretName: "datadog-operator-apikey"
        keyName: "api-key"
      appSecret:
        secretName: "datadog-operator-appkey"
        keyName: "app-key"
    registry: "public.ecr.aws/datadog"
    tags:
      - "env:dev"
    kubelet:
      tlsVerify: false
  features:
    remoteConfiguration:
      enabled: true
    kubeStateMetricsCore:
      enabled: true
    clusterChecks:
      enabled: true
      useClusterChecksRunners: true
    orchestratorExplorer:
      enabled: true
    npm:
      enabled: true
    usm:
        enabled: true
    apm:
      instrumentation:
        enabled: true
        targets:
          # - name: "java-target"
          #   namespaceSelector:
          #     matchNames:
          #       - "NAMESPACE_NAME"
          #   podSelector:
          #     matchLabels:
          #       dd: "java"
          #   ddTraceVersions:
          #     java: "1"
          - name: "default-target"
            ddTraceVersions:
              java: "1"
              python: "4"
              js: "5"
              # php: "1"
              # dotnet: "3"
              # ruby: "2"
            namespaceSelector:
              matchNames: ${NAMESPACES_NAMES}
    logCollection:
      enabled: false
      containerCollectAll: false
  override:
    clusterAgent:
      image:
        tag: latest # cluster-agent has no fixed mayor version image tag
      nodeSelector:
        karpenter.sh/nodepool: "system"
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
        - effect: "NoExecute"
          operator: "Exists"
          tolerationSeconds: 300
      # extraConfd:
      #   configDataMap:
      #     <INTEGRATION_NAME>.yaml: |-
      #       cluster_check: true
      #       init_config:
      #         - <INIT_CONFIG>
      #       instances:
      #         - <INSTANCES_CONFIG>
    nodeAgent:
      image:
        tag: "7" # helm chart is released slower than node agent image, so pin to latest minor version
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
        - effect: "NoExecute"
          operator: "Exists"
          tolerationSeconds: 300
EOF
  }
}

function ensure-backup() {
  helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
  helm repo update
  helm upgrade --install velero -n velero --create-namespace vmware-tanzu/velero -f "${DIRNAME}/velero.yaml" \
    --set configuration.backupStorageLocation[0].name="default" \
    --set configuration.backupStorageLocation[0].provider="aws" \
    --set configuration.backupStorageLocation[0].bucket="${ACCOUNT_ID}-${CLUSTER_NAME}-velero-backups" \
    --set configuration.backupStorageLocation[0].config.region="${REGION}" \
    --set configuration.volumeSnapshotLocation[0].name="default" \
    --set configuration.volumeSnapshotLocation[0].provider="aws" \
    --set configuration.volumeSnapshotLocation[0].config.region="${REGION}" \
    --set serviceAccount.server.annotations."eks\\.amazonaws\\.com/role-arn"="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-velero-irsa"

  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"

    cat <<EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ${NS}-daily-backup
  namespace: velero
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM, so RPO is 24h
  template:
    includedNamespaces:
      - ${NS}
    ttl: 168h0m0s  # 7 days retention
EOF
  done

  NAMESPACES_NAMES="$(echo "${NAMESPACES}" | jq -cr '[.[].name]')"
  cat <<EOF | oc apply -f -
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: cluster-daily-backup
  namespace: velero
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM, RPO = 24h
  template:
    includedNamespaces:
      - "*"  # all namespaces
    excludedNamespaces: ${NAMESPACES_NAMES}
    includeClusterResources: true
    ttl: 168h                          # 7 days retention
EOF

}
# Main
login-to-eks
ensure-cluster-config
ensure-datadog-agent
configure-namespaces
ensure-nginx
ensure-externaldns
ensure-backup

# TODO install SecretManager integration
# https://github.com/aws/secrets-store-csi-driver-provider-aws
