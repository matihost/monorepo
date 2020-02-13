#!/usr/bin/env bash

pkill -f 'minikube tunnel'
minikube tunnel -c

minikube stop
if [ "$(kubectl config current-context 2>/dev/null)" = "minikube" ]; then 
  kubectl config unset current-context &>/dev/null 
fi 
