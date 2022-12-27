#!/usr/bin/env bash

function create_self_signed_cert_for_rilb_gateway() {
  CN="${1:?CN is mandatory}"
  CERT_NAME="${2:?NAME is mandatory}"
  [ ! -f "target/${CERT_NAME}.crt" ] && {
    mkdir -p target
    openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "target/${CERT_NAME}.crt" -newkey rsa:2048 -nodes -keyout "target/${CERT_NAME}.key"
  }
}

function import_existing_object_to_helm() {
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-name="${3}"
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-namespace="${4}"
  kubectl label --overwrite "${1}" "${2}" app.kubernetes.io/managed-by=Helm
}

function disable_default_storageclass() {
  kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
  kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}

# See https://cloud.google.com/stackdriver/docs/managed-prometheus/exporters/kubelet-cadvisor
function scrape_kubelet_metrics_once_per_minute() {
  kubectl patch operatorconfig config -n gmp-public -p '{"collection": {"kubeletScraping": {"interval": "60s"}}}' --type merge
}

# Main
set -x

[ -f "${1?:1st parameter has to be path to kubeconfig}" ] && {
  export KUBECONFIG="${1}"
}

[ -n "${2?:2ns parameter has to be CN for self-signed certificate}" ] && {
  export CN="${2}"
}

create_self_signed_cert_for_rilb_gateway "${CN}" gxlb
import_existing_object_to_helm nl default cluster-config cluster-config
disable_default_storageclass
scrape_kubelet_metrics_once_per_minute
