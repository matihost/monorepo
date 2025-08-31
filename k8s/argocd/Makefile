# https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd#changelog
HELM_CHART_VERSION := latest
ifneq ($(strip $(HELM_CHART_VERSION)),latest)
	VERSION_FLAG :=$(VERSION_FLAG)
endif

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := --dry-run --debug
endif


DEPLOYMENT_NAME := argo-cd
NS := argocd
VALUES := values.yaml
HELM_CHART := argo/argo-cd

ifeq ($(strip $(ENV)),minikube)
CN := argocd.minikube
ENV_FLAGS := --set server.ingress.ingressClassName=nginx
endif

ifeq ($(strip $(ENV)),aks)
CN := argocd.svc.aks-shared1-dev.privatelink.northeurope.azmk8s.io
ENV_FLAGS := --set server.ingress.ingressClassName=nginx
endif


init: ## add repo
	helm repo add argo https://argoproj.github.io/argo-helm

update-repo: ## update repo, show current latest version of the chart
	helm repo update argo

show-repo: update-repo ## show current version of chart repo
	helm search repo $(HELM_CHART)

install: update-repo create-certs ## install/upgrade
ifndef ADMIN_PASS
	$(error Env ADMIN_PASS is not defined.)
endif
	@helm upgrade --install $(DEPLOYMENT_NAME) $(HELM_CHART) --namespace $(NS) --create-namespace --values $(VALUES) $(VERSION_FLAG) \
		$(ENV_FLAGS) \
		--set global.domain="$(CN)" \
		--set configs.secret.argocdServerAdminPassword=$$(htpasswd -bnBC 10 "" $(ADMIN_PASS) | tr -d ':\n' | sed 's/$2y/$2a/') && \
	kubectl apply -f files


create-certs:
ifndef ENV
	$(error Env ENV is not defined.)
endif
	@kubectl get ns argocd >/dev/null 2>&1 || kubectl create ns argocd
	@if [ ! -e "/tmp/$(CN).key" ]; then \
	  echo "Generating TLS certs for CN=$(CN)..."; \
	  openssl req -x509 -sha256 -nodes -days 365 \
	    -subj "/CN=$(CN)" \
	    -newkey rsa:2048 \
	    -keyout "/tmp/$(CN).key" \
	    -out "/tmp/$(CN).crt" >/dev/null 2>&1; \
	fi
	@if [ ! -e "/tmp/argo-all.key" ]; then \
	  echo "Generating TLS certs for CN=*..."; \
	  openssl req -x509 -sha256 -nodes -days 365 \
	    -subj "/CN=*" \
	    -newkey rsa:2048 \
	    -keyout "/tmp/argo-all.key" \
	    -out "/tmp/argo-all.crt" >/dev/null 2>&1; \
	fi
	@kubectl create secret tls argocd-server-tls \
		--key="/tmp/$(CN).key" \
		--cert="/tmp/$(CN).crt" \
		-n argocd --dry-run=client -o yaml | kubectl apply -f -
	@kubectl create secret tls argocd-tls-all \
		--key="/tmp/argo-all.key" \
		--cert="/tmp/argo-all.crt" \
		-n argocd --dry-run=client -o yaml | kubectl apply -f -

uninstall: ## uninstall
	helm uninstall $(DEPLOYMENT_NAME) -n $(NS)

get-pods: ## get Pods for deployment
	kubectl get pods -l app.kubernetes.io/instance=$(DEPLOYMENT_NAME) -n $(NS)

template: ## to see what is going to be deployed
	helm template $(DEPLOYMENT_NAME) $(HELM_CHART) --namespace $(NS) --create-namespace --values $(VALUES) $(VERSION_FLAG) $(DEBUG_FLAG)

get-default-values: update-repo ## show default values of helm
	helm show values $(HELM_CHART) $(VERSION_FLAG) > default-values-$(HELM_CHART_VERSION).yaml

show-deployed-resources: ## show deployed resources
	helm get manifest $(DEPLOYMENT_NAME) -n $(NS)

show-deployed-all-info: ## show deployed Helm all information
	helm get all $(DEPLOYMENT_NAME) -n $(NS)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help install
