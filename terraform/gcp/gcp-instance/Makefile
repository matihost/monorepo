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

CURRENT_ACCOUNT_SSH_USER := $(shell gcloud config get-value account 2>/dev/null | sed -E "s/[.@]/_/g")

init-terraform:
	cd stage/instance && terragrunt init -upgrade=true

run: init-terraform prepare ## setup free-tier eliglible Ubuntu instance, make run [MODE=apply]
	cd stage/instance && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)

ssh: ## ssh to VM instance using ssh client via ssh key added to OS login
	PUBLIC_IP="$$(cd stage/instance && terragrunt output -raw public_ip)" && ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=accept-new $(CURRENT_ACCOUNT_SSH_USER)@$${PUBLIC_IP}

check-startup: ## check VM startup script logs
	PUBLIC_IP="$$(cd stage/instance && terragrunt output -raw public_ip)" && ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=accept-new $(CURRENT_ACCOUNT_SSH_USER)@$${PUBLIC_IP} sudo journalctl -u google-startup-scripts.service

gssh: ## ssh to VM instance using gcloud
	@VM_NAME="$$(cd stage/instance && terragrunt output -raw instance_name)" && gcloud compute ssh "$${VM_NAME}"

test: ## test Nginx instance
	@PUBLIC_IP="$$(cd stage/instance && terragrunt output -raw public_ip)" && curl "http://$${PUBLIC_IP}:80"

show-state: ## show terraform.state
	terraform state list
	terraform show


prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login
	gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.cloud.vm.pub

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
