#!/usr/bin/env bash
kubectl config use-context minikube || echo "Minikube not present in kube context" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  # demonstrate NetworkPolicy
  # deny-all - recommended to put on Namespaces
  # echoserver-allow-from-all-namespaces - traffic only to pods with label app=echoserver
  echo "---
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: learning
  name: deny-all
spec:
  podSelector: {}
  ingress: []
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  namespace: learning
  name: echoserver-allow-from-all-namespaces
spec:
  podSelector:
    matchLabels:
      app: echoserver
  ingress:
  - from:
    - namespaceSelector: {}
  " | kubectl apply -f - -n learning
  # EchoServer has to run as root hence it requires psp:privileged
  echo "---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: learning:privileged
  namespace: learning
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp:privileged
subjects:
- kind: ServiceAccount
  name: default
  namespace: learning
  " | kubectl apply -f -
  kubectl create deployment echoserver --image=registry.k8s.io/echoserver:1.10
  kubectl expose deployment echoserver --type=NodePort --port=80 --target-port=8080
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.minikube" -newkey rsa:2048 -keyout /tmp/echoserver.learning.minikube.key -out /tmp/echoserver.learning.minikube.crt
  echo "---
apiVersion: v1
kind: Secret
metadata:
  name: echoserver.learning.minikube
  namespace: learning
data:
  tls.crt: $(base64 -w 0 /tmp/echoserver.learning.minikube.crt)
  tls.key: $(base64 -w 0 /tmp/echoserver.learning.minikube.key)
type: kubernetes.io/tls
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echoserver
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  tls:
  - hosts:
    - echoserver.learning.minikube
    secretName: echoserver.learning.minikube
  rules:
  - host: echoserver.learning.minikube
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echoserver
            port:
              number: 80" |
    kubectl apply -f - -n learning

  while [ -z "$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}" | xargs)" ]; do
    sleep 1
    echo "Awaiting for LoadBalancer for Ingress..."
  done
  INGRESS_IP="$(kubectl get ingress echoserver -n learning -o jsonpath="{.status..ip}")"
  CHANGED=$(grep -c "${INGRESS_IP} echoserver.learning.minikube" /etc/hosts)
  [ "${CHANGED}" -eq 0 ] && echo "update hosts" && sudo -E sh -c "echo \"${INGRESS_IP} echoserver.learning.minikube\" >> /etc/hosts" || echo "hosts already present"
}
