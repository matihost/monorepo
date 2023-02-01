#!/usr/bin/env bash

# https://github.com/openshift/installer/issues/4232
# the only way to pass google credentials is via GSA key file path
export GOOGLE_CREDENTIALS="files/gcp-prerequisites/target/key.json"

function usage() {
  echo -e "Usage: $(basename "$0") -n | --name cluster-name

Deploys OKD in GCP.

Samples:
$(basename "$0") -n okd
or
$(basename "$0") okd
"
}

function install_okd_binaries() {
  CURRENT_VERSION="$(curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r ".tag_name")"
  INSTALLED_VERSION="$(openshift-install version 2>/dev/null | grep 'openshift-install' | sed -E 's/^openshift-install (.*)/\1/')"
  [ "${CURRENT_VERSION}" = "${INSTALLED_VERSION}" ] || {
    cd "$(mktemp -d)" &&
      curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r ".assets[] | select(.browser_download_url | contains(\"openshift-install-linux\")) |.browser_download_url" |
      xargs curl -sSL | tar -zx -o openshift-install &&
      sudo mv openshift-install /usr/local/bin
    curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r ".assets[] | select(.browser_download_url | contains(\"openshift-client-linux-4\")) |.browser_download_url" |
      xargs curl -sSL | tar -zx -o oc &&
      sudo mv oc /usr/local/bin &&
      curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r ".assets[] | select(.browser_download_url | contains(\"ccoctl-linux\")) |.browser_download_url" |
      xargs curl -sSL | tar -zx -o ccoctl &&
      sudo mv ccoctl /usr/local/bin &&
      echo "oc, openshift-install and ccoctl installed"
  }
}

function ensure_gsa_key_present() {
  [ -e "${GOOGLE_CREDENTIALS}" ] || (
    cd files/gcp-prerequisites &&
      mkdir -p target &&
      make run &&
      make use-okd-installer-sa &&
      make get-okd-installer-sa-key >target/key.json
  )
}

function backup_okd_install_state() {
  GS_BUCKET="gs://$(gcloud config get project)-${1}-installation"
  gsutil mb -c standard -l us-east1 "${GS_BUCKET}"
  gsutil versioning set on "${GS_BUCKET}"
  cd target &&
    tar -Jcvf "${1}.tar.xz" "${1}" &&
    gsutil cp "${1}.tar.xz" "${GS_BUCKET}/" &&
    rm "${1}.tar.xz"
}

# Main

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

install_okd_binaries
ensure_gsa_key_present

CLUSTER_CONFIG_DIR="target/${CLUSTER_NAME}"
mkdir -p "${CLUSTER_CONFIG_DIR}"

# create OKD manifests
template=$(cat files/install-config.template.yaml)
eval "echo -e \"${template}\"" >"${CLUSTER_CONFIG_DIR}"/install-config.yaml

openshift-install create manifests --dir="${CLUSTER_CONFIG_DIR}" --log-level debug

# customization for ingress
cp files/cluster-ingress-default-ingresscontroller.yaml "${CLUSTER_CONFIG_DIR}/manifests/"

openshift-install create cluster --dir="${CLUSTER_CONFIG_DIR}" --log-level debug

backup_okd_install_state "${CLUSTER_NAME}"
