#!/usr/bin/env bash
kubectl config use-context minikube || echo "Minikube not present in kube context" && \
  kubectl create ns learning && \
  kubectl config set-context --current --namespace learning && \
  kubectl create deployment echoserver --image=k8s.gcr.io/echoserver:1.4 && \
  kubectl expose deployment echoserver --type=LoadBalancer --port=80 --target-port=8080
