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

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif


run: pre-all ## configures Worflow Identity and Config Connector for GKE namespace
	@terraform validate && \
	terraform $(MODE_STR)

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

pre-all: init-terraform
	rm -rf target
ifndef KNS
	$(error KNS is mandatory)
endif
	-@terraform workspace new $(KNS)@$(CURRENT_PROJECT) &>/dev/null
	terraform workspace select $(KNS)@$(CURRENT_PROJECT)

test: # configure NS default with SA default wiht workflow identity
	$(MAKE) run CLUSTER_NAME=shared1 KNS=default KSAS='["default"]'
	kubectl apply -f tests -n default
	sleep 30
	kubectl get storagebucket -n default

apply-for-istio:
	$(MAKE) run CLUSTER_NAME=shared1 KNS=istio-system KSAS='["default","istio-reader-service-account","istiod", "istiod-service-account"]'
	$(MAKE) run CLUSTER_NAME=shared1 KNS=istio-ingress KSAS='["default","istio-ingressgateway"]'


apply-for-sample-istio:
	$(MAKE) run CLUSTER_NAME=shared1 KNS=sample-istio KSAS='["default","httpbin"]'

init-terraform:
	terraform init -upgrade=true

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy prerequisites
