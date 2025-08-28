#!/usr/bin/env bash

CLUSTER_RG="${1:?CLUSTER_RG is required}"
SUB="${2:?SUB is required}"
CLUSTER_NAME="${3:?CLUSTER_NAME is required}"
REGION="${4:?REGION is required}"
ACR_NAME="${5:?ACR_NAME is required}"
NAMESPACES="${6:?NAMESPACES is required}"

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
    NC_VIEW_GROUP_OBJ_ID="$(az ad group show --group "aks-${CLUSTER_NAME}-ns-${NS}-view" --query id -o tsv 2>/dev/null)"
    NC_EDIT_GROUP_OBJ_ID="$(az ad group show --group "aks-${CLUSTER_NAME}-ns-${NS}-edit" --query id -o tsv 2>/dev/null)"

    [ -n "$(kubectl get ns "${NS}" --no-headers --ignore-not-found)" ] || {
      kubectl create ns "${NS}"
    }
    helm upgrade --install "ns-${NS}-config" -n cluster-config --create-namespace "${DIRNAME}/namespace-config-chart" \
      --set namespace="${NS}" \
      --set-json quota="$(echo "${QUOTA}" | jq -r)" \
      --set rbac.view="${NC_VIEW_GROUP_OBJ_ID}" \
      --set rbac.edit="${NC_EDIT_GROUP_OBJ_ID}"
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
  # --set google.project="${PROJECT}" \
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
}

# Main
login-to-aks || { exit 1; }
ensure-cluster-config
# ensure-external-secrets-operator
ensure-external-secrets-operator-installed-locally
configure-namespaces
