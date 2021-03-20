#!/usr/bin/env bash
# Creates kubecontext entry to access GKE Master via Istio Ingress Gateway
# So that access to GKE Master API can be allowed from peered VPC.

PROXIED_API_SERVER=${1:-'https://kubernetes.internal.gke.shared1.dev.gcp.testing'}

CURRENT_CONTEXT="$(kubectl config current-context)"
CURRENT_CONTEXT_USER="$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${CURRENT_CONTEXT}\")].context.user}")"
NAMESPACE="$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${CURRENT_CONTEXT}\")].context.namespace}")"

PROXIED_CONTEXT="proxied-${CURRENT_CONTEXT}"
kubectl config set-cluster "${PROXIED_CONTEXT}" --server="${PROXIED_API_SERVER}" --insecure-skip-tls-verify=true
kubectl config set-context "${PROXIED_CONTEXT}" --cluster="${PROXIED_CONTEXT}" --namespace="${NAMESPACE}" --user="${CURRENT_CONTEXT_USER}"
kubectl config use-context "${PROXIED_CONTEXT}"
