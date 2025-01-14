.EXPORT_ALL_VARIABLES:

ENV := current

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true

run: init ## usage: make run [ENV=current] [MODE=apply] [DEBUG=false])
	cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +
	find . -name "node_modules" -exec rm -rf {} +

# pre-apply: ## import undeletable KMS related state
# 	-@terragrunt import google_kms_key_ring.us-central1-keyring projects/${CURRENT_PROJECT}/locations/us-central1/keyRings/us-central1-keyring
# 	-@terragrunt import google_kms_crypto_key.gke-etcd-enc-key projects/${CURRENT_PROJECT}/locations/us-central1/keyRings/us-central1-keyring/cryptoKeys/gke-etcd-enc-key

# pre-destroy: ## remove no removable KMS related data from state before actually destroying cluster
# 	-@terragrunt state rm google_kms_key_ring.us-central1-keyring
# 	-@terragrunt state rm google_kms_crypto_key.gke-etcd-enc-key


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
