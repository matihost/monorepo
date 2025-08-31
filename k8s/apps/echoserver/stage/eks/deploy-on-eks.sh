#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

kubectl config set-context --current --namespace learning

set -x

helm upgrade --install echoserver "$(dirname "${SCRIPT_DIR}")" -n learning \
  --set ingress.tls.enabled=false \
  --set ingress.host="*" \
  --set ingress.class=internal-alb \
  --set networkPolicy.enabled=false

# while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
#   sleep 1
#   echo "Awaiting for LoadBalancer for Ingress..."
# done
# INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
# CHANGED=$(grep -c "${INGRESS_IP} ${CN}" /etc/hosts)
# [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} ${CN}\" >> /etc/hosts" || echo "hosts already present"
# }
