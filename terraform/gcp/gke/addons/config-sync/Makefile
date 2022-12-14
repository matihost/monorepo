.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
CLUSTER_NAME := shared1
TF_VAR_project := $(CURRENT_PROJECT)

TF_VAR_cluster_name := $(CLUSTER_NAME)

apply: init-terraform prerequisites ## installs Standalone Config Sync on GKE
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

status: ## retrieve Config Sync status
	-nomos status
	kubectl logs -n config-management-system -l app=git-importer -c git-sync
	kubectl logs -n config-management-system -l app=git-importer -c importer

destroy: ## uninstalls Standalone Config Sync
	kubectl delete configmanagement config-management
	sleep 30
	kubectl delete -f target/config-sync-operator.yaml
	terraform plan && terraform destroy -auto-approve && 	rm -rf target

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init-terraform:
	terraform init -upgrade=true

prerequisites:
	cd prerequisites && $(MAKE) run


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy prerequisites
