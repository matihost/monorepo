.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
CLUSTER_NAME := shared1

KSAS := ["default"]
ROLES := ["roles/editor"]

TF_VAR_project := $(CURRENT_PROJECT)

TF_VAR_cluster_name := $(CLUSTER_NAME)

TF_VAR_gsa_roles := ${ROLES}
TF_VAR_kns_sas := $(KSAS)
TF_VAR_kns := $(KNS)


apply: pre-all ## configures Worflow Identity and Config Connector for GKE namespace
	@terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

destroy: ## removes GSA and binding making Config Connector disabled
	terraform plan && terraform destroy -auto-approve

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

pre-all:
	rm -rf target
ifndef KNS
	$(error KNS is mandatory)
endif
	terraform init -upgrade=true
	-@terraform workspace new $(KNS)@$(CURRENT_PROJECT) &>/dev/null
	terraform workspace select $(KNS)@$(CURRENT_PROJECT)

test: # configure NS default with SA default wiht workflow identity
	$(MAKE) apply CLUSTER_NAME=shared1 KNS=default KSAS='["default"]'
	kubectl apply -f tests -n default
	sleep 30
	kubectl get storagebucket -n default

apply-for-istio-system:
	$(MAKE) apply CLUSTER_NAME=shared1 KNS=istio-system KSAS='["default","istio-egressgateway-service-account","istio-external-ingressgateway-service-account","istio-ingressgateway-service-account","istio-reader-service-account","istiod-service-account"]'


apply-for-sample-istio:
	$(MAKE) apply CLUSTER_NAME=shared1 KNS=sample-istio KSAS='["default","httpbin"]'

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy prerequisites
