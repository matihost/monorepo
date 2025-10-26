SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

deploy-on-minikube: ## deploys OPA Gatekeeper on Minikube (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-gatekeeper.yaml -v

deploy-on-gke: ## deploys OPA Gatekeeper on GKE (assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke deploy-gatekeeper.yaml -v

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube deploy-on-gke
