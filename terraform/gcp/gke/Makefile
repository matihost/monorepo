SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

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

CLUSTER_NAME := shared1-dev

init:
	cd stage/$(CLUSTER_NAME) && terragrunt init -upgrade=true --backend-bootstrap --non-interactive

run: init ## setup GKE cluster: make run [CLUSTER_NAME=shared1-dev] [MODE=apply]
	@cd stage/$(CLUSTER_NAME) && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)

show-state: ## show state
	cd stage/$(CLUSTER_NAME) && terragrunt state list && terragrunt show

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


scale-down: ## scale down to 0 nodes cluster
	gcloud container clusters resize $(CLUSTER_NAME) --zone="$(shell cd stage/$(CLUSTER_NAME) && terragrunt output location)" --num-nodes=0 --async --quiet

scale-up: ## scale up to 1 nodes cluster
	gcloud container clusters resize $(CLUSTER_NAME) --zone="$(shell cd stage/$(CLUSTER_NAME) && terragrunt output location)" --num-nodes=1 --async --quiet

open-tunnel: ## opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
	-@kill `pgrep -a ssh | grep dev-vpc-bastion | cut -f1 -d' '`
	gcloud compute ssh dev-vpc-bastion -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8888:127.0.0.1:8888 -f sleep 36000

setup-kubecontext: ## creates ~/.kube/config context to for GKE cluster
	gcloud container clusters get-credentials $(CLUSTER_NAME) --zone="$(shell cd stage/$(CLUSTER_NAME) && terragrunt output location)"


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
