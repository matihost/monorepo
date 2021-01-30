.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)


apply: pre-all pre-apply ## setup KMS
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve


show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: pre-destroy ## destroy resources
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

pre-apply: ## import undeletable KMS related state
	-@terraform import google_kms_key_ring.gke-keyring projects/${CURRENT_PROJECT}/locations/us-central1/keyRings/shared-dev-keyring
	-@terraform import google_kms_crypto_key.gke-etcd-enc-key projects/${CURRENT_PROJECT}/locations/us-central1/keyRings/shared-dev-keyring/cryptoKeys/gke-etcd-enc-key

pre-destroy: ## remove no removable KMS related data from state before actually destroying cluster
	-@terraform state rm google_kms_key_ring.gke-keyring
	-@terraform state rm google_kms_crypto_key.gke-etcd-enc-key


pre-all:
	terraform init -upgrade=true


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
