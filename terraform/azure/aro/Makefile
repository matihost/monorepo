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


ENV := dev-northeurope-shared1

init: init-tf-backend
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init ## setup ARO: make run [ENV=dev-northeurope-shared1] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)


CLUSTER_RG = "$(shell cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)"
CLUSTER_NAME = "$(shell cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)"

kubeconfig: ## configure kubeconfig with break-glass credentials (kubeadmin)
	oc login -u kubeadmin -p "$(shell az aro list-credentials --name "$(CLUSTER_NAME)" --resource-group "$(CLUSTER_RG)" 2>/dev/null | jq -r ".kubeadminPassword")" "$(shell cd stage/$(ENV) && terragrunt output -raw api_url)"


get-break-glass-credentials: ## retrieve the break glass credentials for ARO (kubeadmin)
	az aro list-credentials --name "$(CLUSTER_NAME)" --resource-group "$(CLUSTER_RG)" 2>/dev/null

open-webconsole: ## open ARO web console
	ARO_CONSOLE_URL="$(shell cd stage/$(ENV) && terragrunt output -raw console_url 2>/dev/null)" && \
	xdg-open "$${ARO_CONSOLE_URL}" || sensible-browser "$${ARO_CONSOLE_URL}" || x-www-browser "$${ARO_CONSOLE_URL}" || gnome-open "$${ARO_CONSOLE_URL}"

get-sp-expiration-date: ## check ARO cluster ServicePrincipal credential expiration date
	az ad app credential list --id "$$(az aro show --name $(CLUSTER_NAME) --resource-group $(CLUSTER_RG) --query servicePrincipalProfile.clientId -o tsv)" --query "[].endDateTime" -o tsv

rotate-sp-credentials: ## automated ServicePrincipal credential rotation will check if the service principal exists and rotate or create a new service principal.
	az aro update --refresh-credentials --name $(CLUSTER_NAME) --resource-group $(CLUSTER_RG)


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
