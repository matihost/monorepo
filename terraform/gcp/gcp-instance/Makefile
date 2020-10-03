CURRENT_PROJECT := $(shell gcloud config get-value project)

apply: prepare ## setup free-tier eliglible Ubuntu instance
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve


CURRENT_ACCOUNT_SSH_USER := $(shell gcloud config get-value account | sed -E "s/[.@]/_/g")
ssh: ## ssh to VM instance using ssh client via ssh key added to OS login
	ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=accept-new $(CURRENT_ACCOUNT_SSH_USER)@$(shell terraform output public_ip)

gssh: ## ssh to VM instance using gcloud
	gcloud compute ssh $(shell terraform output instance_name)

test: ## test Nginx instance
	curl http://$(shell terraform output public_ip):80

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy VM instance
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	terraform plan && terraform destroy -auto-approve

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login
	gcloud compute os-login ssh-keys add --key-file ~/.ssh/id_rsa.cloud.vm.pub

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
