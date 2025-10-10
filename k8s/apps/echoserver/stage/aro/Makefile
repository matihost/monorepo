SHELL := /bin/bash

NS := learning
APP := echoserver
CN := $(APP).$(NS).apps.devshared1.northeurope.aroapp.io

k8s:
	@[[ "$$(kubectl config current-context)" == *"aroapp"* ]] || { echo "Not logged to ARO cluster"; exit 1; }
	@kubectl config set-context --current --namespace $(NS)


create-cert: k8s
	@kubectl get ns $(NS) >/dev/null 2>&1 || kubectl create ns $(NS)
	@if [ ! -e "/tmp/all.key" ]; then \
	  openssl req -x509 -sha256 -nodes -days 365 \
	    -subj "/CN=*" \
	    -newkey rsa:2048 \
	    -keyout "/tmp/all.key" \
	    -out "/tmp/all.crt" >/dev/null 2>&1; \
	fi
	kubectl create secret tls $(APP) \
		--key="/tmp/all.key" \
		--cert="/tmp/all.crt" \
		-n $(NS) --dry-run=client -o yaml | kubectl apply -f -


deploy-via-helm: create-cert ## deploys app via Helm
	helm upgrade --install $(APP) "../.." -n $(NS) --create-namespace \
	  --set ingress.host="$(CN)" \
	  --set ingress.class=openshift-default \
	  --set prometheus.alert.enabled=true

uninstall-helm: k8s ## uninstall
	helm uninstall $(APP) -n $(NS)


deploy-via-argocd: minikube create-cert ## deploys via ArgoCD
	kubectl apply -f argocd.yaml -n argocd

test: ## e2e test
	curl -ksSL https://$(CN)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help
