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

run: init ## setup AKS: make run [ENV=dev-northeurope-shared1] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

get-cluster-admin-entraid-group-name: ## get name of EntraId group member who are assigned cluster-admin to the AKS cluster
	cd stage/$(ENV) && terragrunt output -raw cluster-admin-entraid-group 2>/dev/null

kubeconfig: ## configure kubeconfig with AKS credentials of your Azure user with non-interactive mode (by default interactive, device logon method is used)
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		az aks get-credentials --resource-group "$${CLUSTER_RG}" --name "$${CLUSTER_NAME}" --overwrite-existing  && \
		kubelogin convert-kubeconfig -l azurecli

breakglass-kubeconfig: ## configure kubeconfig witn non-EntraID clusterAdmin local account, requires that cluster local_account_disabled is false, use only when other method of accessing the cluster failed
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		az aks get-credentials --admin --resource-group "$${CLUSTER_RG}" --name "$${CLUSTER_NAME}" --overwrite-existing  && \
		kubelogin convert-kubeconfig -l azurecli

acr-login: ## login to ACR registry associated with AKS cluster
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
	ACR_NAME="$$(cd stage/$(ENV) && terragrunt output -raw acr_name 2>/dev/null)" && \
		az acr login \
			--resource-group "$${CLUSTER_RG}" \
			--name "$${ACR_NAME}"

get-possible-upgrades: ## check possible upgrades for AKS
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		az aks get-upgrades \
			--resource-group "$${CLUSTER_RG}" \
			--name "$${CLUSTER_NAME}" \
			-o table

upgrade-control-plane: ## upgrade control plane to new versions
ifndef NEW_VERSION
	$(error Environment NEW_VERSION is not defined. Check make get-possible-upgrades)
endif
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		az aks upgrade \
				--resource-group "$${CLUSTER_RG}" \
				--name "$${CLUSTER_NAME}" \
				--kubernetes-version $(NEW_VERSION) \
				--control-plane-only \
				--yes

get-node-pools-names: ## get names of configured nodepools
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		az aks nodepool list \
			--resource-group "$${CLUSTER_RG}" \
			--cluster-name "$${CLUSTER_NAME}" \
			--query "[].name" \
			-o tsv

upgrade-node-pools: ## upgrades node pool to current control plane version
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		NODE_POOLS="$$(az aks nodepool list --resource-group "$${CLUSTER_RG}" --cluster-name "$${CLUSTER_NAME}" --query "[].name" -o tsv 2>/dev/null)" && \
		AKS_VERSION="$$(az aks show --resource-group "$${CLUSTER_RG}" --name "$${CLUSTER_NAME}" --query kubernetesVersion -o tsv)" && \
		for pool in $${NODE_POOLS}; do \
			echo "Upgrading node pool: $${pool} to $${AKS_VERSION}..." && \
			az aks nodepool upgrade \
				--resource-group "$${CLUSTER_RG}" \
				--cluster-name "$${CLUSTER_NAME}" \
				--name "$${pool}" \
				--kubernetes-version "$${AKS_VERSION}" \
				--max-unavailable 2 \
				--yes; \
		done

get-container-registries: ## get names of configured container registries
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		az acr list \
			--resource-group "$${CLUSTER_RG}" \
			--query "[].name" \
			-o tsv

delete-node: ## delete node gracefully
ifndef NODE_POOL
	$(error Environment NODE_POOL is not defined. Check make get-node-pools-names)
endif
ifndef NODE_NAME
	$(error Environment NODE_NAME is not defined. Check kubectl get nodes)
endif
	CLUSTER_RG="$$(cd stage/$(ENV) && terragrunt output -raw cluster_rg 2>/dev/null)" && \
		CLUSTER_NAME="$$(cd stage/$(ENV) && terragrunt output -raw cluster_name 2>/dev/null)" && \
		kubectx "$${CLUSTER_NAME}" && \
		kubectl cordon "$(NODE_NAME)" && \
		kubectl drain "$(NODE_NAME)" --delete-emptydir-data --ignore-daemonsets --timeout 300s && \
		az aks nodepool delete-machines \
			--resource-group "$${CLUSTER_RG}" \
			--cluster-name "$${CLUSTER_NAME}" \
			--name "$(NODE_POOL)" \
			--machine-names "$(NODE_NAME)"

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

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
