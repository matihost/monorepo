#!/usr/bin/env bash

function import_existing_object_to_helm() {
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-name="${3}"
  kubectl annotate --overwrite "${1}" "${2}" meta.helm.sh/release-namespace="${4}"
  kubectl label --overwrite "${1}" "${2}" app.kubernetes.io/managed-by=Helm
}

function disable_default_storageclass() {
  kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
}

# Main
set -x

[ -f .terraform/kubeconfig ] && {
  export KUBECONFIG=.terraform/kubeconfig
}

import_existing_object_to_helm nl default cluster-config cluster-config
disable_default_storageclass
