#!/usr/bin/env bash
function usage() {
  echo -e "Usage: $(basename "$0") -e|--env minikube/gke -p jenkins_admin_pass [env]

Ensure Jenkins jobs are setup in  Jenkins in 'env'.

Samples:
# setup jobs in Jenkins deployed on minikube
$(basename "$0") -e minikube -p jenkins_admin_pass
or
$(basename "$0") minikube -p jenkins_admin_pass

# setup jobs in Jenkins deployed on GKE
$(basename "$0") -e gke -p jenkins_admin_pass
"
}

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
  -p | --jenkins_admin_pass)
    PASS="$2"
    shift
    ;;
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

ENV=${ENV:-${PARAMS[0]}}

if [[ -z "$ENV" || -z "$PASS" ]]; then
  usage
  exit 1
fi

ansible-playbook ensure-jobs.yaml -v -e env="${ENV}" -e jenkins_admin_pass="${PASS}"
