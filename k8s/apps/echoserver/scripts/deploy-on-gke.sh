#!/usr/bin/env bash
[[ "$(kubectl config current-context)" == "gke"* ]] || echo "Not logged to GKE cluster" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.gke" -newkey rsa:2048 -keyout /tmp/echoserver.learning.gke.key -out /tmp/echoserver.learning.gke.crt
  # GKE tweaks in variables:
  # PSP privileged cluster role is different thatn psp:privileged
  # GKE 1.18 does not support v1 ingress yet
  # Ingress needs gce-internal ingressclass to deploy via Internal Load Balancer
  # NetworkPolicy has to be improved - as current one block svcneg - making ingress not working
  helm upgrade --install echoserver .. -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.gke.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.gke.key)" \
    --set pspPrivilegedClusterRole=gce:podsecuritypolicy:privileged \
    --set ingress.version="v1beta1" \
    --set ingress.host=echoserver.learning.gke \
    --set ingress.class=gce-internal \
    --set networkPolicy.enabled=false

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for LoadBalancer for Ingress..."
  done
  INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  CHANGED=$(grep -c "${INGRESS_IP} echoserver.learning.gke" /etc/hosts)
  [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} echoserver.learning.gke\" >> /etc/hosts" || echo "hosts already present"
  echo "To test call: curl -k https://echoserver.learning.gke/"
}
