#!/usr/bin/env bash
kubectl config use-context minikube || echo "Minikube not present in kube context" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  kubectl create deployment echoserver --image=k8s.gcr.io/echoserver:1.4
  kubectl expose deployment echoserver --type=NodePort --port=80 --target-port=8080
  echo "---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: echoserver
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - echoserver.learning.minikube
  rules:
  - host: echoserver.learning.minikube
    http:
      paths:
      - path: /
        backend:
          serviceName: echoserver
          servicePort: 80" |
    kubectl apply -f - -n learning

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for LoadBalancer for Ingress..."
  done
  INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  CHANGED=$(grep -c "${INGRESS_IP} echoserver.learning.minikube" /etc/hosts)
  [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} echoserver.learning.minikube\" >> /etc/hosts" || echo "hosts already present"
}
