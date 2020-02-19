#!/usr/bin/env bash

function ensurePlaybookRequirements(){
  [ -x /usr/local/bin/helm ] || (
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/
  )
  pip3 show openshift &>/dev/null || {
    pip3 install openshift --user
    pip3 install --pre --upgrade kubernetes --user
    pip3 install kubernetes-validate --user
  }
}

function usage(){
echo -e "Usage: `basename $0` -e|--env minikube/gke [env]

Deploys Jenkins in 'env'.
Assumes kubectl is logged to 'env' cluster already.

Samples:
# deploy to minikube
`basename $0` -e minikube
or
`basename $0` minikube

# deploy to gke
`basename $0` -e gke
"    
}

ensurePlaybookRequirements


while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help|help) usage; exit 1;;
  -e|--env) ENV="$2"; shift;;
  *) PARAMS+=("$1");; # save it in an array for later
esac; shift; done
set -- "${PARAMS[@]}" # restore positional parameters

ENV=${ENV:-${PARAMS[0]}}

if [[ -z "$ENV" ]]; then 
  usage
  exit 1
fi 

ansible-playbook deploy-jenkins.yaml -v -e env=${ENV} && (
  echo "Jenkins Url: https://$(kubectl get ingress ci-jenkins -n ci -o jsonpath="{.spec.rules[0].host}")"
  echo "User: admin Password: $(kubectl get secret --namespace ci ci-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -d)"
)