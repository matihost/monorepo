#!/usr/bin/env bash

ACCOUNT_ID="${1:?CLUSTER_NAME is required}"
CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
REGION="${3:?REGION is required}"
NAMESPACES="${4:?NAMESPACES is required}"

set -e
set -x

DIRNAME="$(dirname "$0")"

function login-to-eks() {
  # login to AWS - assuming running as IAM principal being registered via aws_eks_access_entry and aws_eks_access_policy_association
  aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"
}

#  EKS does not contain K8S metrics server
# https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html
# TODO switch to Helm https://artifacthub.io/packages/helm/metrics-server/metrics-server for upgrades
function ensure-metrics-server() {
  [ -n "$(kubectl get deployment metrics-server -n kube-system --no-headers --ignore-not-found)" ] || {
    rm -rf target/metrics-server
    mkdir -p target/metrics-server
    cat <<EOF >target/metrics-server/kustomization.yaml
resources:
  - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

patches:
  - path: customization-patch.yaml
EOF

    cat <<EOF >target/metrics-server/customization-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
spec:
  template:
    spec:
      nodeSelector:
        karpenter.sh/nodepool: "system"
      tolerations:
        - key: "CriticalAddonsOnly"
          operator: "Exists"
        - effect: "NoExecute"
          operator: "Exists"
          tolerationSeconds: 300
EOF
    kubectl apply -k target/metrics-server
    rm -rf target/metrics-server
  }
}

function ensure-cluster-config() {
  helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
    --set clusterName="${CLUSTER_NAME}" \
    --set region="${REGION}"
}

function configure-namespaces() {
  for NAMESPACE in $(echo "${NAMESPACES}" | jq -cr '.[]'); do

    NS="$(echo "${NAMESPACE}" | jq -r ".name")"
    QUOTA="$(echo "${NAMESPACE}" | jq -r ".quota")"

    IRSA_ROLE=""
    IRSA_POLICY="$(echo "${NAMESPACE}" | jq -r ".irsa_policy")"
    [[ -n "${IRSA_POLICY}" && "${IRSA_POLICY}" != "null" ]] && {
      IRSA_ROLE="${CLUSTER_NAME}-${NS}-irsa"
    }

    [ -n "$(kubectl get ns "${NS}" --no-headers --ignore-not-found)" ] || {
      kubectl create ns "${NS}"
    }
    helm upgrade --install "ns-${NS}-config" -n cluster-config --create-namespace "${DIRNAME}/namespace-config-chart" \
      --set namespace="${NS}" \
      --set aws.accountId="${ACCOUNT_ID}" \
      --set irsaRole="${IRSA_ROLE}" \
      --set-json quota="$(echo "${QUOTA}" | jq -r)"
  done
}

# Main
login-to-eks
ensure-cluster-config
ensure-metrics-server
configure-namespaces

# TODO install SecretManager integration
# https://github.com/aws/secrets-store-csi-driver-provider-aws

# TODO install EKS ExternalDNS
# https://www.stacksimplify.com/aws-eks/aws-alb-ingress/learn-to-master-updating-aws-route53-recordsets-from-kubernetes-using-externaldns/
