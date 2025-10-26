SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)


apply: init-terraform ## register GKE in Anthos
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

destroy: ## unregister GKE from Anthos
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init-terraform:
	terraform init -upgrade=true

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
