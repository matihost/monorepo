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
	ifndef REGION
		REGION := eusc-de-east-1
	endif
else
	DEPLOY_PATH := stage/$(ENV)
	ifndef REGION
		REGION := us-east-1
	endif
endif

init: prepare
	cd $(DEPLOY_PATH) && terragrunt run --all -- init -upgrade=true

run-one: prepare ## ## setup VPC in one region: make run [ENV=dev] [REGION=us-east-1] [MODE=apply]
	cd $(DEPLOY_PATH)/$(REGION) && terragrunt init -upgrade=true && terragrunt validate && terragrunt $(MODE_STR) $(TG_FLAGS)

run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd $(DEPLOY_PATH) && terragrunt run --all validate && terragrunt run --all $(MODE_STR) $(TG_FLAGS)

ssh: ## ssh to VPC bastion host
	eval $(shell cd $(DEPLOY_PATH)/$(REGION) && terragrunt output bastion_ssh)

nat-ssh: ## ssh to NAT instance
	eval "$(shell cd $(DEPLOY_PATH)/$(REGION) && terragrunt output nat_ssh)"

webserver-ssm-ssh: ## ssh to webserver instance over SSM
	aws ssm start-session --target "$(shell cd $(DEPLOY_PATH)/$(REGION) && terragrunt output webserver_id)"

expose_bastion_proxy_locally: ## expose bastion's HTTP proxy locally
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || eval "$(shell cd $(DEPLOY_PATH) && terragrunt output expose_bastion_proxy_locally)"

shutdown_local_bastion_proxy: ## shutdown tunneled bastion's HTTP proxy
	@[ "$(shell sudo ss -antl |grep -c 8888)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:8888)

test: expose_bastion_proxy_locally ## test private  webeserver
	eval "$(shell cd $(DEPLOY_PATH) && terragrunt output connect_via_bastion_proxy)"


show-state: ## show state
	cd $(DEPLOY_PATH)/$(REGION) && terragrunt state list && terragrunt show

show-bastion-user-data: ## show bastion user data value
	aws ec2 describe-instance-attribute --instance-id $(shell cd $(DEPLOY_PATH) && terragrunt output bastion_id) --attribute userData --output text --query "UserData.Value" | base64 -d


clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.aws.vm; }
