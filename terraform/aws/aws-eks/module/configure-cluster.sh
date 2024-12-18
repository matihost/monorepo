#!/usr/bin/env bash

ACCOUNT_ID="${1:?CLUSTER_NAME is required}"
CLUSTER_NAME="${2:?CLUSTER_NAME is required}"
REGION="${3:?REGION is required}"
NAMESPACES="${4:?NAMESPACES is required}"

set -e
set -x

DIRNAME="$(dirname "$0")"

# login to AWS - assuming running as IAM principal being registered via aws_eks_access_entry and aws_eks_access_policy_association
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

helm upgrade --install cluster-config -n cluster-config --create-namespace "${DIRNAME}/cluster-config-chart" \
  --set clusterName="${CLUSTER_NAME}" \
  --set region="${REGION}"

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
