.EXPORT_ALL_VARIABLES:

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


run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

ssh: ## ssh to VPC bastion host
	eval $(shell cd stage/$(ENV) && terragrunt output bastion_ssh)

nat-ssh: ## ssh to NAT instance
	eval "$(shell cd stage/$(ENV) && terragrunt output nat_ssh)"

webserver-ssm-ssh: ## ssh to webserver instance over SSM
	aws ssm start-session --target "$(shell cd stage/$(ENV) && terragrunt output webserver_id)"

expose_bastion_proxy_locally: ## expose bastion's HTTP proxy locally
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || eval "$(shell cd stage/$(ENV) && terragrunt output expose_bastion_proxy_locally)"

shutdown_local_bastion_proxy: ## shutdown tunneled bastion's HTTP proxy
	@[ "$(shell sudo ss -antl |grep -c 8888)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:8888)

test: expose_bastion_proxy_locally ## test private  webeserver
	eval "$(shell cd stage/$(ENV) && terragrunt output connect_via_bastion_proxy)"


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

show-bastion-user-data: ## show bastion user data value
	aws ec2 describe-instance-attribute --instance-id $(shell cd stage/$(ENV) && terragrunt output bastion_id) --attribute userData --output text --query "UserData.Value" | base64 -d


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
