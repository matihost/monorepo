.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

APPROVE := true
ifeq ($(strip $(APPROVE)),true)
	APPROVE_STR := -auto-approve
endif


apply: init-terraform prepare ## deploy ApigeeX, usage: make apply [DEBUG=true APPROVE=false]
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply $(APPROVE_STR)

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy ApigeeX resources
	rm -rf target
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init-terraform:
	terraform init -upgrade=true

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*


deploy-provider: ## deploys exchange-rate-web app as container on VM
	gcloud compute instances create-with-container exchange-rate-web \
    --container-image quay.io/matihost/exchange-rate:latest --container-restart-policy=always \
    --subnet private-subnet-us-east1 --zone us-east1-b --no-address --metadata enable-oslogin=TRUE \
    --machine-type=e2-micro \
    --image-project=cos-cloud --image-family=cos-stable --boot-disk-size=10GB

destroy-provider: ## destroy exchange-rate-web VM
	gcloud compute instances delete exchange-rate-web --zone us-east1-b --quiet

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
