SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif

run: init-terraform  ## setup user IAM roles and binding
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform $(MODE_STR)

use-okd-installer-sa: ## create new gcloud configuration with okd-installer Google Service Account
	@-terraform output -raw sa-okd-installer-key > /tmp/okd-installer.json
	@-gcloud config configurations create $(CURRENT_PROJECT)-okd-installer-sa 2>/dev/null
	-gcloud config configurations activate $(CURRENT_PROJECT)-okd-installer-sa
	-gcloud auth activate-service-account okd-installer@$(CURRENT_PROJECT).iam.gserviceaccount.com --key-file=/tmp/okd-installer.json --project=$(CURRENT_PROJECT)
	-gcloud config set compute/region us-central1
	-gcloud config set compute/zone us-central1-a
	@-rm -rf /tmp/okd-installer.json

get-okd-installer-sa-key: ## get okd-installer Google Service Account key
	@-terraform output -raw sa-okd-installer-key

show-state: ## show terraform.state
	terraform state list
	terraform show


init-terraform:
	terraform init -upgrade=true


google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
