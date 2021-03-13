#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
kubectl config use-context minikube || echo "Minikube not present in kube context" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.minikube.testing" -newkey rsa:2048 -keyout /tmp/echoserver.learning.minikube.testing.key -out /tmp/echoserver.learning.minikube.testing.crt
  helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning \
    --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.minikube.testing.crt)" \
    --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.minikube.testing.key)" \
    --set networkPolicy.enabled=true

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for LoadBalancer for Ingress..."
  done
  INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  CHANGED=$(grep -c "${INGRESS_IP} echoserver.learning.minikube.testing" /etc/hosts)
  [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} echoserver.learning.minikube.testing\" >> /etc/hosts" || echo "hosts already present"
}
