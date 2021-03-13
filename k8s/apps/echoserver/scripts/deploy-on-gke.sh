#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
[[ "$(kubectl config current-context)" == "gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.internal.gke.shared1.dev.gcp.testing" -newkey rsa:2048 -keyout /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.key -out /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.crt
  # in case ingress class is istio - it requires TLS secret in istio-system namespace
  kubectl create -n istio-system secret tls echoserver --key="/tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.key" --cert="/tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.crt" || echo "ignoring..."
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  # In case GKE 1.18 or lower - it does not support v1 ingress yet - use ingress version: v1beta1
  # Ingress needs gce-internal ingressclass to deploy via Internal Load Balancer
  # NetworkPolicy has to be improved - as current one block svcneg - making ingress not working
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.internal.gke.shared1.dev.gcp.testing.key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.version="v1beta1" \
    --set ingress.host=echoserver.learning.internal.gke.shared1.dev.gcp.testing \
    --set ingress.class=istio

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for Ingress readyness..."
  done
  #INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  echo -e "To test call: 'curl -ksSL https://echoserver.learning.internal.gke.shared1.dev.gcp.testing'"
}
