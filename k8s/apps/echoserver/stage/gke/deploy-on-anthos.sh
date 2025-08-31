#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

[[ "$(kubectl config current-context)" == *"gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning &>/dev/null
  kubectl config set-context --current --namespace learning
  [ -e "/tmp/${CN}.key" ] || {
    openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=${CN}" -newkey rsa:2048 -keyout "/tmp/${CN}.key" -out "/tmp/${CN}.crt"
  }
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  # Expose via Anthos MCS & MCI instead of svc & ingress
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 "/tmp/${CN}.crt")" --set ingress.tls.key="$(base64 -w 0 /tmp/"${CN}".key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.enabled=false \
    --set svc.enabled=false \
    --set anthos.ingress.enabled=true
}
