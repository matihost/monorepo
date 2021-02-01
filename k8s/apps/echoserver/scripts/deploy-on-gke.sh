#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
[[ "$(kubectl config current-context)" == "gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.shared.dev.gke" -newkey rsa:2048 -keyout /tmp/echoserver.learning.shared.dev.gke.key -out /tmp/echoserver.learning.shared.dev.gke.crt
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  # GKE 1.18 does not support v1 ingress yet
  # Ingress needs gce-internal ingressclass to deploy via Internal Load Balancer
  # NetworkPolicy has to be improved - as current one block svcneg - making ingress not working
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.shared.dev.gke.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.shared.dev.gke.key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.version="v1beta1" \
    --set ingress.host=echoserver.learning.gke.shared.dev \
    --set ingress.class=gce-internal

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for LoadBalancer for Ingress..."
  done
  #INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  # TODO update Cloud DNS with igress A entry
  echo -e "To test call: 'curl -x http://localhost:8888 -ksSL https://echoserver.learning.gke.shared.dev'"
}
