GITHUB_PAT := $(shell gh auth token)

deploy-on-minikube: ## deploys GitHub Actions Runner Controller on Minikube (assumes kubecontext points to Minikube )
	@ansible-playbook -i inventory/minikube deploy-arc.yaml -e github_token="$(GITHUB_PAT)" -v

undeploy-from-minikube: ## deploys GitHub Actions Runner Controller on Minikube (assumes kubecontext points to Minikube )
	@ansible-playbook -i inventory/minikube undeploy-arc.yaml -e github_token="$(GITHUB_PAT)" -v

deploy-on-gke: ## deploys GitHub Actions Runner Controller on GKE (assumes kubecontext points to GKE cluster )
	@ansible-playbook -i inventory/gke deploy-arc.yaml -e github_token="$(GITHUB_PAT)" -v

undeploy-from-gke: ## deploys GitHub Actions Runner Controller on GKE (assumes kubecontext points to GKE cluster )
	@ansible-playbook -i inventory/gke undeploy-arc.yaml -e github_token="$(GITHUB_PAT)" -v

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube deploy-on-gke
