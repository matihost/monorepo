#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

CN="echoserver.learning.testing.minikube"

kubectl config use-context minikube || echo "Minikube not present in kube context" && {
  kubectl create ns learning &>/dev/null
  kubectl config set-context --current --namespace learning
  [ -e "/tmp/${CN}.key" ] || {
    openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=${CN}" -newkey rsa:2048 -keyout "/tmp/${CN}.key" -out "/tmp/${CN}.crt"
  }
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning \
    --set ingress.tls.crt="$(base64 -w 0 /tmp/${CN}.crt)" \
    --set ingress.tls.key="$(base64 -w 0 /tmp/${CN}.key)" \
    --set ingress.host="${CN}" \
    --set ingress.class=external-alb \
    --set networkPolicy.enabled=false

  # while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
  #   sleep 1
  #   echo "Awaiting for LoadBalancer for Ingress..."
  # done
  # INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  # CHANGED=$(grep -c "${INGRESS_IP} ${CN}" /etc/hosts)
  # [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} ${CN}\" >> /etc/hosts" || echo "hosts already present"
}
