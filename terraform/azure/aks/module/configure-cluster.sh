#!/usr/bin/env bash

CLUSTER_RG="${1:?CLUSTER_RG is required}"
SUB="${2:?SUB is required}"
TENANT_ID="${3:?TENANT_ID is required}"
CLUSTER_NAME="${4:?CLUSTER_NAME is required}"
REGION="${5:?REGION is required}"
ACR_NAME="${6:?ACR_NAME is required}"
NGINX_INGRESS_IP="${7:?NGINX_INGRESS_IP is required}"
NAMESPACES="${8:?NAMESPACES is required}"

# set -e
set -x

DIRNAME="$(dirname "$0")"

function login-to-aks() {
  az aks get-credentials --subscription "${SUB}" --resource-group "${CLUSTER_RG}" --name "${CLUSTER_NAME}" --overwrite-existing &&
    kubelogin convert-kubeconfig -l azurecli
}

function import_existing_object_to_helm() {
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-name="${3}"
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-namespace="${4}"
  kubectl label --overwrite "${1}" "${2}" app.kubernetes.io/managed-by=Helm
}

function import_existing_ns_object_to_helm() {
  kubectl annotate --overwrite "${1}" "${2}" -n "${3}" meta.helm.sh/release-name="${4}"
  kubectl annotate --overwrite "${1}" "${2}" -n "${3}" meta.helm.sh/release-namespace="${5}"
  kubectl label --overwrite "${1}" "${2}" -n "${3}" app.kubernetes.io/managed-by=Helm
}

function disable_default_storageclass() {
  kubectl patch storageclass default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}

function ensure-cluster-config() {
  disable_default_storageclass
  # import_existing_object_to_helm oauths cluster cluster-config cluster-config

  # has to be with --force - otherwise imported resources to Helm - are not updated with Helm
  # https://github.com/helm/helm/issues/11040#issuecomment-1154702487
  helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
    --force \
    --set clusterName="${CLUSTER_NAME}" \
    --set region="${REGION}"
}

function configure-namespaces() {
  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"
    QUOTA="$(echo "${NAMESPACE}" | jq -r ".quota")"
    NS_VIEW_GROUP_OBJ_ID="$(az ad group show --group "aks-${CLUSTER_NAME}-ns-${NS}-view" --query id -o tsv 2>/dev/null)"
    NS_EDIT_GROUP_OBJ_ID="$(az ad group show --group "aks-${CLUSTER_NAME}-ns-${NS}-edit" --query id -o tsv 2>/dev/null)"
    NS_EDIT_WORKLOAD_IDENTITY_USER_ASSIGNED_CLIENT_ID="$(az identity show --name "aks-${CLUSTER_NAME}-ns-${NS}-edit" --subscription "${SUB}" --resource-group "${CLUSTER_RG}" --query 'clientId' -o tsv 2>/dev/null)"
    NS_KEY_VAULT_NAME="$(echo -n "${NS}" | sha256sum)"
    NS_KEY_VAULT_NAME="${CLUSTER_NAME}-${NS_KEY_VAULT_NAME:0:6}"
    NS_KEY_VAULT_URL="$(az keyvault show --name "${NS_KEY_VAULT_NAME}" --subscription "${SUB}" --resource-group "${CLUSTER_RG}" --query 'properties.vaultUri' -o tsv 2>/dev/null)"

    [ -n "$(kubectl get ns "${NS}" --no-headers --ignore-not-found)" ] || {
      kubectl create ns "${NS}"
    }
    helm upgrade --install "ns-${NS}-config" -n cluster-config --create-namespace "${DIRNAME}/namespace-config-chart" \
      --set namespace="${NS}" \
      --set-json quota="$(echo "${QUOTA}" | jq -r)" \
      --set workload_identity.tenantId="${TENANT_ID}" \
      --set workload_identity.clientId="${NS_EDIT_WORKLOAD_IDENTITY_USER_ASSIGNED_CLIENT_ID}" \
      --set vault.url="${NS_KEY_VAULT_URL}" \
      --set rbac.view="${NS_VIEW_GROUP_OBJ_ID}" \
      --set rbac.edit="${NS_EDIT_GROUP_OBJ_ID}"
  done
}

function ensure-external-secrets-operator() {
  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update
  DEPLOYMENT_NAME=external-secrets
  HELM_CHART=external-secrets/external-secrets
  # helm search repo ${HELM_CHART}
  helm upgrade --install ${DEPLOYMENT_NAME} ${HELM_CHART} --namespace kube-system --create-namespace
  # --version $(HELM_CHART_VERSION) --debug
  # to avoid:
  # https://external-secrets-webhook.kube-system.svc:443/validate-external-secrets-io-v1-secretstore?timeout=5s":
  # no endpoints available for service "external-secrets-webhook"
  wait-for-svc kube-system external-secrets-webhook || { exit 1; }
}

wait-for-svc() {
  local namespace=$1
  local service=$2
  local timeout=${3:-300}
  local interval=${4:-5}

  echo "Waiting up to $timeout seconds for service '$service' in namespace '$namespace' to have endpoints..."

  local end=$((SECONDS + timeout))

  while [ $SECONDS -lt $end ]; do
    if kubectl get endpoints "$service" -n "$namespace" -o jsonpath='{.subsets[*].addresses[*].ip}' | grep -q .; then
      echo "Service $service has endpoints"
      return 0
    fi
    echo "Still waiting..."
    sleep "${interval}"
  done

  echo "Timeout: Service $service has no endpoints after $timeout seconds"
  return 1
}

function ensure-external-secrets-operator-installed-locally() {
  az acr login \
    --resource-group "${CLUSTER_RG}" \
    --subscription "${SUB}" \
    --name "${ACR_NAME}"
  DEPLOYMENT_NAME=external-secrets
  HELM_CHART=external-secrets/external-secrets
  HELM_CHART_VERSION=0.19.2
  HELM_CHART_APP_VERSION="v${HELM_CHART_VERSION}"
  REPO_URL="${ACR_NAME}.azurecr.io"
  helm repo add external-secrets https://charts.external-secrets.io
  helm repo update
  helm pull "${HELM_CHART}" --version "${HELM_CHART_VERSION}"
  helm push "external-secrets-${HELM_CHART_VERSION}.tgz" "oci://${REPO_URL}/external-secrets"
  docker pull "oci.external-secrets.io/external-secrets/external-secrets:${HELM_CHART_APP_VERSION}"
  docker tag "oci.external-secrets.io/external-secrets/external-secrets:${HELM_CHART_APP_VERSION}" "${REPO_URL}/external-secrets/external-secrets:${HELM_CHART_APP_VERSION}"
  docker push "${REPO_URL}/external-secrets/external-secrets:${HELM_CHART_APP_VERSION}"
  rm external-secrets-${HELM_CHART_VERSION}.tgz
  helm upgrade --install "${DEPLOYMENT_NAME}" "oci://${REPO_URL}/external-secrets/external-secrets" --namespace kube-system --create-namespace \
    --version "${HELM_CHART_VERSION}" \
    --set image.repository="${REPO_URL}/external-secrets/external-secrets" \
    --set webhook.image.repository="${REPO_URL}/external-secrets/external-secrets" \
    --set certController.image.repository="${REPO_URL}/external-secrets/external-secrets"
  # to avoid:
  # https://external-secrets-webhook.kube-system.svc:443/validate-external-secrets-io-v1-secretstore?timeout=5s":
  # no endpoints available for service "external-secrets-webhook"
  wait-for-svc kube-system external-secrets-webhook || { exit 1; }
}

function is_internal_ip() {
  local ip="$1"

  if [[ "$ip" =~ ^10\. ]] ||
    [[ "$ip" =~ ^172\.1[6-9]\. ]] ||
    [[ "$ip" =~ ^172\.2[0-9]\. ]] ||
    [[ "$ip" =~ ^172\.3[0-1]\. ]] ||
    [[ "$ip" =~ ^192\.168\. ]]; then
    echo "true"
  else
    echo "false"
  fi
}

function ensure-nginx() {
  [ -n "${NGINX_INGRESS_IP}" ] && {
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    # Azure K8S Service Annotations:
    # https://cloud-provider-azure.sigs.k8s.io/topics/loadbalancer/#loadbalancer-annotations
    # https://learn.microsoft.com/en-us/previous-versions/azure/aks/ingress-tls?tabs=azure-cli#use-a-static-public-ip-address
    helm upgrade --install ingress-nginx -n kube-system ingress-nginx/ingress-nginx \
      --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group="${CLUSTER_RG}" \
      --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal="$(is_internal_ip "${NGINX_INGRESS_IP}")" \
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="${CLUSTER_NAME}-nginx-ingress" \
      --set controller.service.loadBalancerIP="${NGINX_INGRESS_IP}" \
      --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
    # TODO using annotation to provide IP does not work - even when recommended:
    # Error syncing load balancer: failed to ensure load balancer: findMatchedPIPByLoadBalancerIP: cannot find public IP with IP address 68.219.211.66 in resource group dev
    # --set controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-ipv4="${NGINX_INGRESS_IP}"
  }
}

# Main
login-to-aks || { exit 1; }
ensure-cluster-config
ensure-nginx
# ensure-external-secrets-operator
ensure-external-secrets-operator-installed-locally
configure-namespaces
