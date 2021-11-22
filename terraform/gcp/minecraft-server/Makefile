.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)

TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_external_access_cidrs := ["$(WHOAMI)/32"]

# uncomment to run terraform in debug mode
# TF_LOG := DEBUG

apply: init-terraform prepare ## setup Minecraft Server VM, usage make apply PASS=pass_for_minecraft_rcon
ifndef PASS
	$(error Env PASS is not defined. Provider password for Minecraft rcon is required. Usage make apply PASS=pass_for_minecraft_rcon OP_USER=minecraftusername)
endif
ifndef OP_USER
	$(error Env OP_USER is not defined. Minecraft operator/admin user is required. Usage make apply PASS=pass_for_minecraft_rcon OP_USER=minecraftusername)
endif
	@terraform validate && \
	terraform plan -lock=false -var='server_rcon_pass=$(PASS)' -var='server_op_user=$(OP_USER)' && \
	terraform apply -auto-approve -var='server_rcon_pass=$(PASS)' -var='server_op_user=$(OP_USER)'

ssh: ## ssh to Minecraft Server instance
	gcloud compute ssh --strict-host-key-checking=no `gcloud compute instances list --filter="name~'^minecraft-server-.*$$'" --format=json | jq -rc .[].name`

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy Minecraft Server resources
	rm -rf target
	terraform destroy -auto-approve -var='server_rcon_pass=whatever_as_we_destroy' -var='server_op_user=whatever_as_we_destroy'

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

init-terraform:
	terraform init -upgrade=true

shutdown: ## resize instance group to zero
	gcloud compute instance-groups managed resize minecraft-server-prod-01 --zone=us-central1-a --size=0

bring-up: ## resize instance group to one
	gcloud compute instance-groups managed resize minecraft-server-prod-01 --zone=us-central1-a --size=1

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
