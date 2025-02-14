.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif


init: prepare
	cd stage/current && terragrunt init -upgrade=true

run: init ## usage: make run MODE=plan [DEBUG=true])
	cd stage/current && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)

CURRENT_PROJECT := $(shell gcloud config get-value project 2>/dev/null)
use-editor-sa: ## create new gcloud configuration with editor Google Service Account
	@-cd stage/current && terragrunt output -raw sa-editor-key > /tmp/editor.json
	@-gcloud config configurations create $(CURRENT_PROJECT)-editor-sa 2>/dev/null
	-gcloud config configurations activate $(CURRENT_PROJECT)-editor-sa
	-gcloud auth activate-service-account editor@$(CURRENT_PROJECT).iam.gserviceaccount.com --key-file=/tmp/editor.json --project=$(CURRENT_PROJECT)
	-gcloud config set compute/region us-central1
	-gcloud config set compute/zone us-central1-a
	@-rm -rf /tmp/editor.json

get-editor-sa-key: ## get editor Google Service Account key
	@-cd stage/current && terragrunt output -raw sa-editor-key

show-state: ## show terraform.state
	cd stage/current && terragrunt state list && terragrunt show

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
