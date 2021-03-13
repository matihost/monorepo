#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
[[ "$(kubectl config current-context)" == "gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  # GKE 1.18 does not support v1 ingress yet
  # Ingress needs gce-internal ingressclass to deploy via Internal Load Balancer
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.enabled=false \
    --set svc.enabled=false \
    --set anthos.ingress.enabled=true
}
