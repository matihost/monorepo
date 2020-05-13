#!/usr/bin/env bash
if minikube status &>/dev/null; then
  minikube dashboard
else
  echo "Minikube is NOT running. Run start-minikube.sh first"
  exit 1
fi
