#!/usr/bin/env bash
set -e
set -x

# shellcheck disable=SC2034
GSA="${1}"
PROJECT="${2}"
KNS="${3}"
KSAS="${4}"

export KUBECONFIG=.terraform/kubeconfig

# set a default project ID for newly created resources via Config Connector Custom Resources
kubectl annotate namespace "${KNS}" cnrm.cloud.google.com/project-id="${PROJECT}" --overwrite

# workflow identity
for KSA in ${KSAS}; do
  kubectl annotate serviceaccount "${KSA}" iam.gke.io/gcp-service-account="${GSA}" -n "${KNS}" --overwrite
done
# ensure Config Connector in namespaced mode
[ "$(kubectl get configconnectors configconnector.core.cnrm.cloud.google.com -o jsonpath='{.spec.mode}')" != 'namespaced' ] && {

  kubectl apply -f - <<EOF
apiVersion: core.cnrm.cloud.google.com/v1beta1
kind: ConfigConnector
metadata:
  # the name is restricted to ensure that there is only ConfigConnector resource installed in your cluster
  name: configconnector.core.cnrm.cloud.google.com
spec:
 mode: namespaced
EOF

}

# install Config Connector Context for KNS
kubectl apply -f target/config-connector.yaml

# wait for ConfigConnector Stateful set to initiate
sleep 60

# ensure Config Connector Context for KNS is running
kubectl wait -n cnrm-system \
  --for=condition=Ready pod \
  --timeout=240s \
  -l cnrm.cloud.google.com/component=cnrm-controller-manager \
  -l cnrm.cloud.google.com/scoped-namespace="${KNS}"
