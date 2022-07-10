#!/usr/bin/env bash

function ensurePlaybookRequirements() {
  [ -x /usr/local/bin/helm ] || (
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    helm repo add stable https://charts.helm.sh/stable
  )
  pip3 show openshift &>/dev/null || {
    pip3 install openshift --user
    pip3 install --pre --upgrade kubernetes --user
    pip3 install kubernetes-validate --user
  }
}

function usage() {
  echo -e "Usage: $(basename "$0") -e|--env gke -b|--backup-id <GCS_DIRECTORY>

Deploys Jenkins in 'env'.
Assumes kubectl is logged to 'env' cluster already.
Assumes gcloud is point to gcproject where GKE is deployed

Samples:
# recover backup from GCS
$(basename "$0") -e gke --backup-id 20220710154200
"
}

ensurePlaybookRequirements

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help | help)
    usage
    exit 1
    ;;
  -e | --env)
    ENV="$2"
    shift
    ;;
  -b | --backup-id)
    BACKUP_ID="$2"
    shift
    ;;
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

ENV=${ENV:-${PARAMS[0]}}

if [[ -z "$ENV" || -z "$BACKUP_ID" ]]; then
  usage
  exit 1
fi

ansible-playbook recover-from-backup.yaml -v -e env="${ENV}" -e backup_id="${BACKUP_ID}"
