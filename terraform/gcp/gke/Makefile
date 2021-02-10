.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
ACCESS_FROM_LAPTOP := true
ENCRYPT_ETCD := false
ENABLE_PSP := false
CLUSTER_NAME := shared
REGION := us-central1

TF_VAR_external_access_ip := $(WHOAMI)
TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_expose_master_via_external_ip := $(ACCESS_FROM_LAPTOP)
TF_VAR_encrypt_etcd := $(ENCRYPT_ETCD)
TF_VAR_enable_pod_security_policy := $(ENABLE_PSP)
TF_VAR_cluster_name := $(CLUSTER_NAME)
TF_VAR_region := $(REGION)

# uncomment to run terraform in debug mode
# TF_LOG := DEBUG

apply: ## setup GKE cluster
	@terraform validate && \
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
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init:
	terraform init -upgrade=true

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
