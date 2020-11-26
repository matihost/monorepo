#!/usr/bin/env bash
kubectl config use-context minikube || echo "Minikube not present in kube context" && {
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
  openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.testing" -newkey rsa:2048 -keyout /tmp/echoserver.learning.testing.key -out /tmp/echoserver.learning.testing.crt
  helm install echoserver . -n learning --set ingress.tls.crt="$(base64 -w 0 /tmp/echoserver.learning.testing.crt)" --set ingress.tls.key="$(base64 -w 0 /tmp/echoserver.learning.testing.key)"
}
