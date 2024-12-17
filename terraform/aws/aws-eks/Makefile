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


ENV := dev

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)


kubeconfig: ## generate kubeconfig entry for EKS cluster
	aws eks --region $(shell cd stage/$(ENV) && terragrunt output -raw region) update-kubeconfig --name $(shell cd stage/$(ENV) && terragrunt output -raw cluster_name)

kubeconfig-oidc: ## test OIDC setup and provide instruction to work
ifndef ISSUER_URL
	$(error Environment ISSUER_URL is not defined. For keycloak it would some some: https://id.yourdomain.com/realms/NAME_OF_REALM)
endif
ifndef CLIENT_ID
	$(error Environment CLIENT_ID is not defined. For keycloak it would be realm oidc Client ID, for example: eks)
endif
ifndef CLIENT_SECRET
	$(error Environment CLIENT_SECRET is not defined. For keycloak it would be realm oidc Client ID credentials secret)
endif
	kubectl oidc-login setup \
		--oidc-issuer-url=$(ISSUER_URL) \
		--oidc-client-id=$(CLIENT_ID) \
		--oidc-client-secret=$(CLIENT_SECRET)


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
