.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)

TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_external_access_cidrs := ["$(WHOAMI)/32"]

# uncomment to run terraform in debug mode
# TF_LOG := DEBUG

apply: init-terraform prepare ## setup Open VPN
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

ssh: ## ssh to instance (via External IP since VPN Gateway has to be exposed via public IP)
	ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=no ubuntu@$(shell terraform output vpn_gateway_external_ip)

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy OpenVPN resources
	rm -rf target
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init-terraform:
	terraform init -upgrade=true

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy