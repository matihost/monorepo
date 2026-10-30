SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

# Istio via Helm

deploy-istio-helm-on-minikube: ## deploys Istio via Helm on Minikube with CNI deployed (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio-helm.yaml -v

undeploy-istio-helm-from-minikube: ## undeploys Istio via Helm on Minikube with CNI deployed (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube undeploy-istio-helm.yaml -v

deploy-istio-helm-on-gke: ## deploys Istio via Helm on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke deploy-istio-helm.yaml -v

undeploy-istio-helm-from-gke: ## undeploys Istio via Helm on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke undeploy-istio-helm.yaml -v

clean: ## clean Terraform cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "terraform.tfstate*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help
