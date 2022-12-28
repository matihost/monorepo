#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

CN="echoserver.learning.internal.gke.shared1.dev.gcp.testing"

[[ "$(kubectl config current-context)" == *"gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning &>/dev/null
  kubectl config set-context --current --namespace learning
  [ -e "/tmp/${CN}.key" ] || {
    openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=${CN}" -newkey rsa:2048 -keyout "/tmp/${CN}.key" -out "/tmp/${CN}.crt"
  }
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/${CN}.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/${CN}.key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.host="${CN}" \
    --set networkPolicy.enabled=true \
    --set ingress.class=istio

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for Ingress readyness..."
  done
  #INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  echo -e "To test call: 'curl -ksSL https://${CN}'"
}
