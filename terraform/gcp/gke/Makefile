CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
ACCESS_FROM_LAPTOP := true

apply: ## setup GKE cluster
	@export TF_VAR_external_access_ip=$(WHOAMI) && \
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	export TF_VAR_expose_master_via_external_ip=$(ACCESS_FROM_LAPTOP) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve && \
	[ "$(ACCESS_FROM_LAPTOP)" = "true" ] && \
    echo "Run 'gcloud container clusters get-credentials shared-dev --zone us-central1-a' to access GKE  from Kubectl" || \
    echo "Run 'source access-gke.sh' to setup GKE access for kubectl etc. commands in current shell";

open-tunnel: ## opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
	-@kill `pgrep -a ssh | grep shared-dev-bastion | cut -f1 -d' '`
	gcloud compute ssh shared-dev-bastion -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8888:127.0.0.1:8888 -f sleep 36000

setup-kubecontext: ## creates ~/.kube/config context to for GKE cluster
	gcloud container clusters get-credentials shared-dev --zone us-central1-a

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy GKE resources
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	export TF_VAR_project=$(CURRENT_PROJECT) && \
	export TF_VAR_expose_master_via_external_ip=$(ACCESS_FROM_LAPTOP) && \
	terraform plan && terraform destroy -auto-approve


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
