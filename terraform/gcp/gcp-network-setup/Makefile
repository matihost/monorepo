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
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)

ssh: ## ssh to VPC bastion host
	eval $(shell cd stage/dev && terragrunt output bastion_instance_ssh_cmd)


list-dns-resolvers: # list inbound CloudDNS resolvers
	gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
