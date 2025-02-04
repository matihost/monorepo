#!/usr/bin/env bash
#!/usr/bin/env bash

PROJECT="${1:?PROJECT is required}"
CLUSTER_NAME_PREFIX="${2:?CLUSTER_NAME_PREFIX is required}"
CLUSTER_NAME_FULL="${3:?CLUSTER_NAME_FULL is required}"
LOCATION="${4:?LOCATION is required}"
ENV="${5:?ENV is required}"
# shellcheck disable=SC2034
CN="${6:?CN for self-signed certificate is required}"
GCP_GSA="${7:?GCP_GSA aka Google Service Account id for ExternalDNS is required}"

set -e
set -x

DIRNAME="$(dirname "$0")"

function login-to-gke() {
  # TODO use region when location indicates a region
  gcloud container clusters get-credentials "${CLUSTER_NAME_FULL}" --zone "${LOCATION}"
}

function ensure-cluster-is-running() {
  [[ "$(gcloud container clusters describe "${CLUSTER_NAME_FULL}" --zone "${LOCATION}" --format="value(status)")" == 'RUNNING' ]]
  kubectl wait --for=condition=available --timeout=300s deployment/gmp-operator -n gmp-system
  kubectl wait --for=condition=Ready pod -l component=gke-metrics-agent -n kube-system --timeout=300s
  kubectl wait --for=condition=Ready pod -l k8s-app=netd -n kube-system --timeout=300s
}

function ensure-cluster-config() {
  # has to be with --force - otherwise imported resources - are not updated with Helm
  # https://github.com/helm/helm/issues/11040#issuecomment-1154702487
  helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
    --set project="${PROJECT}" \
    --set clusterName="${CLUSTER_NAME_PREFIX}" \
    --set env="${ENV}" \
    --set location="${LOCATION}" \
    --force
}

function ensure-external-dns() {

  # Istio CRD are required to be present
  # otherwise External DNS crashes
  # https://github.com/kubernetes-sigs/external-dns/issues/4901#issuecomment-2553221038
  helm repo add istio https://istio-release.storage.googleapis.com/charts
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update
  helm upgrade --install istio-base -n istio-system --create-namespace istio/base
  helm upgrade --install external-dns -n external-dns --create-namespace bitnami/external-dns -f "${DIRNAME}/external-dns.yaml" \
    --set google.project="${PROJECT}" \
    --set 'serviceAccount.annotations.iam\.gke\.io\/gcp-service-account'="${GCP_GSA}@${PROJECT}.iam.gserviceaccount.com"
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
  kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}

# Main
login-to-gke
ensure-cluster-is-running
import_existing_object_to_helm nl default cluster-config cluster-config
import_existing_ns_object_to_helm operatorconfig config gmp-public cluster-config cluster-config
ensure-cluster-config
ensure-external-dns
disable_default_storageclass
