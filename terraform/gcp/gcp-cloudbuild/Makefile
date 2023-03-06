.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

GH_TOKEN := $(shell gh auth token)
GH_REPO_OWNER := matihost
GH_REPO_NAME := monorepo

REGION := us-central1
ZONE_LETTER := a


TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_region := $(REGION)
TF_VAR_zone_letter := $(ZONE_LETTER)
TF_VAR_gh_token := $(GH_TOKEN)
TF_VAR_gh_repo_owner := $(GH_REPO_OWNER)
TF_VAR_gh_repo_name := $(GH_REPO_NAME)
TF_VAR_gh_cloud_build_app_id := $(CLOUD_BUILD_APP_ID)


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
ifndef REGION
	$(error Env REGION is not defined. Usage make run REGION=us-central1 ZONE_LETTER=a)
endif
ifndef ZONE_LETTER
	$(error Env ZONE_LETTER is not defined. Usage make run REGION=us-central1 ZONE_LETTER=a)
endif
	-@terraform workspace new $(CURRENT_PROJECT) &>/dev/null
	terraform workspace select $(CURRENT_PROJECT)


run: pre-all ## usage make run [MODE=apply/plan/destroy]
ifndef CLOUD_BUILD_APP_ID
	$(error Env CLOUD_BUILD_APP_ID is not defined. Usage make run CLOUD_BUILD_APP_ID=12312312)
endif
	terraform $(MODE_STR)

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate* target

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run
