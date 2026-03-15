SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --inputs-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := --non-interactive -- apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := --non-interactive -- destroy -auto-approve
else
	MODE_STR := --non-interactive -- plan
endif


ENV := dev-westeurope-shared1

init: init-tf-backend
	cd stage/$(ENV) && terragrunt run -- init -upgrade=true


run: init ## setup ACR: make run [ENV=dev-northeurope-shared1] [MODE=apply]
	@cd stage/$(ENV) && terragrunt run validate && terragrunt run $(MODE_STR) $(TG_FLAGS)

acr-admin-login: ## login to ACR registry with docker admin credentials
	ACR_NAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_name 2>/dev/null)" && \
	ACR_USERNAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_username 2>/dev/null)" && \
	ACR_PASSWORD="$$(cd stage/$(ENV) && terragrunt output -raw acr_password 2>/dev/null)" && \
		docker login "$${ACR_NAME}.azurecr.io" \
			-u "$${ACR_USERNAME}" \
			-p "$${ACR_PASSWORD}"

acr-login: ## login to ACR registry
	RG="$$(cd stage/$(ENV) && terragrunt output -raw rg 2>/dev/null)" && \
	ACR_NAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_name 2>/dev/null)" && \
		az acr login \
			--resource-group "$${RG}" \
			--name "$${ACR_NAME}"

get-container-registries: ## get names of configured container registries
	RG="$$(cd stage/$(ENV) && terragrunt output -raw rg 2>/dev/null)" && \
		az acr list \
			--resource-group "$${RG}" \
			--query "[].name" \
			-o tsv

make list-repositories: ## list repositories in ACR registry
	ACR_NAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_name 2>/dev/null)" && \
		az acr repository list \
			--name "$${ACR_NAME}" \
			-o tsv

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

init-tf-backend:
	cd stage && ./init_azurerm_tf_backend.sh

whoami: ## show current logon (tenant, subscription, user)
	@az account show

login: ## login to Azure Subscription
	az login

update-pull-secret: ## update ARO cluster pull secret with ACR credentials
	oc get secrets pull-secret -n openshift-config -o template='{{index .data ".dockerconfigjson"}}' | base64 -d > pull-secret.json
	ACR_NAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_name 2>/dev/null)" && \
	ACR_USERNAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_username 2>/dev/null)" && \
	ACR_PASSWORD="$$(cd stage/$(ENV) && terragrunt output -raw acr_password 2>/dev/null)" && \
	jq --arg acr "$${ACR_NAME}.azurecr.io" \
		 --arg user "$${ACR_USERNAME}" \
		 --arg pass "$${ACR_PASSWORD}" \
		 '.auths += {($$acr): {"auth": ($$user + ":" + $$pass | @base64)}}' \
		 pull-secret.json > pull-secret-modified.json && \
	oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=./pull-secret-modified.json && \
	rm pull-secret.json pull-secret-modified.json

show-current-pull-secret: ## show current pull secret
	oc get secrets pull-secret -n openshift-config -o template='{{index .data ".dockerconfigjson"}}' | base64 -d

show-current-runtime-pull-secret: ## show current pull secret from runtime (kubelet config)
	oc exec -n openshift-apiserver `oc get pod -n openshift-apiserver -o jsonpath="{.items[0].metadata.name}"` -- cat /var/lib/kubelet/config.json

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
