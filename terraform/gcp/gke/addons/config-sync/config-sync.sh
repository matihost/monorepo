#!/usr/bin/env bash
set -e
set -x

# shellcheck disable=SC2034
GSA="${1}"
PROJECT="${2}"

# install Nomos in case it is missing, assuming Ubuntu
command -v nomos || {
  gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos ~/bin/nomos
  chmod u+x ~/bin/nomos
}

# when GCP Source repo is empty
# kubectl logs -n config-management-system -l app=git-importer -c git-sync
# returns:
# E0327 20:34:24.919606      13 main.go:352]  "msg"="unexpected error syncing repo, will retry" "error"="error running command: exit status 128: { stdout: \"\", stderr: \"Cloning into '/repo/root'...\\nfatal: Remote branch master not found in upstream origin\\n\" }"
gcloud source repos clone gke-config target/gke-config --project="${PROJECT}"
[ -n "$(ls target/gke-config)" ] || {
  cd target/gke-config
  nomos init
  git add -A
  git commit -a -m 'config-sync initial config structure'
  git push -u origin master
  cd ../..
}

export KUBECONFIG=.terraform/kubeconfig

# install Config Sync operator
kubectl apply -f target/config-management-operator.yaml

# enable Config Sync configuration
kubectl apply -f target/config-management.yaml

timeout="3 minute"
deadline=$(date -ud "${timeout}" +%s)
while [ -z "$(kubectl get sa importer -n config-management-system -o jsonpath="{.metadata.name}" 2>/dev/null | xargs)" ] && [[ $(date -u +%s) -le ${deadline} ]]; do
  sleep 2
  echo "Awaiting for config-management-system/importer KSA"
done
if [ -z "$(kubectl get sa importer -n config-management-system -o jsonpath="{.metadata.name}" 2>/dev/null | xargs)" ]; then
  echo "Config Sync not present? Missing config-management-system/importer KSA in GKE cluster"
  exit 1
fi

# ensure Config Sync is able to read GCP Source Repo
kubectl annotate serviceaccount importer iam.gke.io/gcp-service-account="${GSA}" -n config-management-system --overwrite
