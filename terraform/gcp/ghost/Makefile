.EXPORT_ALL_VARIABLES:

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

init-terraform:
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev MODE=plan [DEBUG=true])
endif
	cd stage/$(ENV) && terragrunt init -upgrade=true

run: init-terraform ## usage: Usage make run ENV=dev MODE=plan [DEBUG=true])
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
	cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
