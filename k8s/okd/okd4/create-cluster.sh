#!/usr/bin/env bash

function usage() {
  echo -e "Usage: $(basename "$0") -n | --name cluster-name -k|--key-file /path/to/gsa/key.json

Deploys OKD in GCP.

Samples:
$(basename "$0") -n okd -k /path/to/gsa/key.json
or
$(basename "$0") okd /path/to/gsa/key.json
"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help | help)
    usage
    exit 1
    ;;
  -n | --name)
    CLUSTER_NAME="$2"
    shift
    ;;
  -k | --key-file)
    KEY_FILE="$2"
    shift
    ;;
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

CLUSTER_NAME=${ENV:-${PARAMS[0]}}
KEY_FILE=${KEY_FILE:-${PARAMS[1]}}

if [[ -z "$CLUSTER_NAME" || -z "$KEY_FILE" ]]; then
  usage
  exit 1
fi

# Main

# https://github.com/openshift/installer/issues/4232
# the only way to pass google credentials is via GSA key file path
export GOOGLE_CREDENTIALS="${KEY_FILE}"

CLUSTER_CONFIG_DIR="target/${CLUSTER_NAME}"
mkdir -p "${CLUSTER_CONFIG_DIR}"

template=$(cat files/install-config.template.yaml)
eval "echo -e \"${template}\"" >"${CLUSTER_CONFIG_DIR}"/install-config.yaml

openshift-install create manifests --dir="${CLUSTER_CONFIG_DIR}" --log-level debug

# customization for ingress
cp files/cluster-ingress-default-ingresscontroller.yaml "${CLUSTER_CONFIG_DIR}/manifests/"

#
# openshift-install create cluster --dir="${CLUSTER_CONFIG_DIR}" --log-level debug
