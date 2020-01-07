#!/usr/bin/env bash
minikube status &>/dev/null
if [ $? -eq 0 ]; then
  minikube dashboard
else
  echo "Minikube is NOT running. Run start-minikube.sh first"
  exit 1
fi
