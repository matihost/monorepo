CURRENT_PROJECT := $(shell gcloud config get-value project)

apply: ## setup GKE cluster
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve && \
	echo "Run 'source access-gke.sh' to setup GKE access for kubectl etc. commands in current shell"

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy VM instance
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	terraform plan && terraform destroy -auto-approve


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
