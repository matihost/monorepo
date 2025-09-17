.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	DEBUG_MODE :=--terragrunt-log-level debug --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve $(DEBUG_MODE)
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve $(DEBUG_MODE)
else
	MODE_STR := plan $(DEBUG_MODE)
endif


ENV := dev-westeurope

init: init-tf-backend
	cd stage/$(ENV) && terragrunt init -upgrade=true --backend-bootstrap --non-interactive


run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

init-tf-backend:
	cd stage && ./init_azurerm_tf_backend.sh

whoami: ## show current logon (tenant, subsription, user)
	@az account show

login: ## login to Azure Subscription
	az login

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
