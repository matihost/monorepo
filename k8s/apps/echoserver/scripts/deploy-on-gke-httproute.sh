#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

CN="echoserver.gxlb.gke.shared1.dev.gcp.testing"

[[ "$(kubectl config current-context)" == *"gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning &>/dev/null
  kubectl config set-context --current --namespace learning
  # GKE tweaks in variables:
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning \
    --set apigateway.enabled=true \
    --set apigateway.route.host="${CN}" \
    --set ingress.enabled=false \
    --set networkPolicy.enabled=false \
    --set apigateway.gateway.name=external \
    --set apigateway.gateway.namespace=gateways

  echo -e "To test call: 'curl -ksSL https://${CN}'"
}
