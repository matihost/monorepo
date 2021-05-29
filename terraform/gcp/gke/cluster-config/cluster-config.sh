#!/usr/bin/env bash

function import_existing_object_to_helm() {
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-name="${3}"
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-namespace="${4}"
  kubectl label --overwrite "${1}" "${2}" app.kubernetes.io/managed-by=Helm
}

# Main

[ -f ../.terraform/kubeconfig ] && {
  export KUBECONFIG=../.terraform/kubeconfig
}

import_existing_object_to_helm nl default cluster-config cluster-config
