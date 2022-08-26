.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)


TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_cluster_name := $(CLUSTER_NAME)
TF_VAR_region := $(REGION)
TF_VAR_zone_letter := $(ZONE_LETTER)



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

init-terraform:
	terraform init -upgrade=true

pre-all: init-terraform
ifndef CLUSTER_NAME
	$(error Env CLUSTER_NAME is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a [MODE=apply])
endif
ifndef REGION
	$(error Env REGION is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a)
endif
ifndef ZONE_LETTER
	$(error Env ZONE_LETTER is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a)
endif
	-@terraform workspace new $(CLUSTER_NAME)@$(CURRENT_PROJECT) &>/dev/null
	terraform workspace select $(CLUSTER_NAME)@$(CURRENT_PROJECT)


run: ## usage make run CLUSTER_NAME=shared1 [MODE=apply/plan/destroy]
	terraform $(MODE_STR)


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run
