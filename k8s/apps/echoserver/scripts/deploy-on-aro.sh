#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

CN="echo.learning.apps.devshared1.northeurope.aroapp.io"
[[ "$(kubectl config current-context)" == *"aroapp"* ]] || echo "Not logged to ARO cluster" && {
  kubectl config set-context --current --namespace learning
  [ -e "/tmp/${CN}.key" ] || {
    openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=${CN}" -newkey rsa:2048 -keyout "/tmp/${CN}.key" -out "/tmp/${CN}.crt"
  }
  oc adm policy add-scc-to-user anyuid -z default -n learning
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning \
    --set ingress.tls.enabled=true \
    --set ingress.tls.crt="$(base64 -w 0 "/tmp/${CN}.crt")" \
    --set ingress.tls.key="$(base64 -w 0 /tmp/"${CN}".key)" \
    --set ingress.host="${CN}" \
    --set ingress.class=openshift-default \
    --set networkPolicy.enabled=false
}
