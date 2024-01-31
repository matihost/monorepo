.EXPORT_ALL_VARIABLES:

IC_API_KEY := $(shell cat $(HOME)/.ibmcloud/apikey.json | jq -r .apikey)

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


ENV := dev

init: prepare
	cd stage/$(ENV) && terragrunt init -upgrade=true


ibm-authentication: ## authenticate ibmcloud CLI and create API key if needed
	ibmcloud login -a https://cloud.ibm.com --sso
	[ -e "$(HOME)/.ibmcloud/apikey.json" ] || { ibmcloud iam api-key-create default --file $(HOME)/.ibmcloud/apikey.json; }


whoami: ## show current user IAM ID
	@ibmcloud iam oauth-tokens --output json | jq -r .iam_token |cut -d" " -f2|cut -d"." -f2 |base64 -d 2>/dev/null |jq -r .iam_id

getaccountid: ## show current IBM Account ID
	@ibmcloud account show --output json | jq -r .account_id

run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

ssh: ## ssh to VPC bastion host
	eval $(shell cd stage/$(ENV) && terragrunt output bastion_ssh)

expose_bastion_proxy_locally: ## expose bastion's HTTP proxy locally
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || eval "$(shell cd stage/$(ENV) && terragrunt output expose_bastion_proxy_locally)"

shutdown_local_bastion_proxy: ## shutdown tunneled bastion's HTTP proxy
	@[ "$(shell sudo ss -antl |grep -c 8888)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:8888)

test: expose_bastion_proxy_locally ## test private  webeserver
	eval "$(shell cd stage/$(ENV) && terragrunt output connect_via_bastion_proxy)"


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show


clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean



prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.ibm.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.ibm.vm; }
