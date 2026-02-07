SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --inputs-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := --non-interactive -- apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := --non-interactive -- destroy -auto-approve
else
	MODE_STR := --non-interactive -- plan
endif

PARTITION := aws

ENV := dev

ifeq ($(strip $(PARTITION)),eusc)
	DEPLOY_PATH := stage/eusc/$(ENV)
else
	DEPLOY_PATH := stage/$(ENV)
endif

init:
	cd $(DEPLOY_PATH) && terragrunt run -- init -upgrade=true

run: init ## setup ECS services: make run [ENV=dev] [MODE=apply]
	@cd $(DEPLOY_PATH) && terragrunt run validate && terragrunt run $(MODE_STR) $(TG_FLAGS)


show-state: ## show state
	cd $(DEPLOY_PATH) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
