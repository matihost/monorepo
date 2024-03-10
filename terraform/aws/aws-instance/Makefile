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


run: init ## setup free-tier eliglible Ubuntu instance, usage: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

ssh: ## ssh to EC2 instance
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(shell cd stage/$(ENV) && terragrunt output ec2_dns)

ssm-ssh: ## ssh to EC2 instance over SSM SSH
	aws ssm start-session --target "$(shell cd stage/$(ENV) && terragrunt output ec2_id)"

show-instance-startup-logs: # show EC2 cloud-init statup logs
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(shell cd stage/$(ENV) && terragrunt output ec2_dns) cat /var/log/cloud-init-output.log


test: ## test Nginx instance
	curl http://$(shell cd stage/$(ENV) && terragrunt output ec2_dns):80


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
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.aws.vm; }
