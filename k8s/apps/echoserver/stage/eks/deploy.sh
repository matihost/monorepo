#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

[[ "$(kubectl config current-context)" == *":eks:"* ]] || echo "Not logged to EKS cluster" && {
  REGION="$(kubectl config current-context | cut -d: -f4)"
  CN="echoserver.learning.${REGION}.dev.aws.testing"

  kubectl config set-context --current --namespace learning
  [ -e "/tmp/${CN}.key" ] || {
    openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=${CN}" -newkey rsa:2048 -keyout "/tmp/${CN}.key" -out "/tmp/${CN}.crt"
  }
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning --set ingress.tls.crt="$(base64 -w 0 "/tmp/${CN}.crt")" --set ingress.tls.key="$(base64 -w 0 "/tmp/${CN}.key")" \
    --set ingress.host="${CN}" \
    --set networkPolicy.enabled=false \
    --set ingress.class=nginx

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..hostname}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for Ingress readyness..."
  done
  #INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..hostname}")"
  echo -e "To test call: 'curl -ksSL https://${CN}'"
}
