#!/usr/bin/env bash

# https://github.com/openshift/installer/issues/4232
# the only way to pass google credentials is via GSA key file path
export GOOGLE_CREDENTIALS="files/gcp-prerequisites/target/key.json"

function ensure_gsa_key_present() {
  [ -e "${GOOGLE_CREDENTIALS}" ] || (
    cd files/gcp-prerequisites &&
      mkdir -p target &&
      make run &&
      make use-okd-installer-sa &&
      make get-okd-installer-sa-key >target/key.json
  )
}

function usage() {
  echo -e "Usage: $(basename "$0") -n | --name cluster-name

Destroy OKD cluster in GCP.

Samples:
$(basename "$0") -n okd
or
$(basename "$0") okd
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
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

CLUSTER_NAME=${ENV:-${PARAMS[0]}}

if [[ -z "$CLUSTER_NAME" ]]; then
  usage
  exit 1
fi

# Main
ensure_gsa_key_present
CLUSTER_CONFIG_DIR="target/${CLUSTER_NAME}"

openshift-install destroy cluster --dir="${CLUSTER_CONFIG_DIR}" --log-level debug
