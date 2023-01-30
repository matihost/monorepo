.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
F_LOG := DEBUG	T
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
	terraform init -upgrade=true

run: init-terraform ## setup VPC: make run [MODE=apply]
	@terraform validate && \
	terraform $(MODE_STR)

ssh: ## ssh to VPC bastion host
	eval $(shell terraform output bastion_instance_ssh_cmd)


list-dns-resolvers: # list inbound CloudDNS resolvers
	gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy resources
	terraform destroy -auto-approve

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login


clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

upgrade-terraform-provider-version: init-terraform


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
