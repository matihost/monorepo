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


ENV := dev

init: prepare
	cd stage/$(ENV) && terragrunt run-all init -upgrade=true

run-one: prepare
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make run-one ENV=dev INSTANCE=ubuntu)
endif
	cd stage/$(ENV)/${INSTANCE} && terragrunt init -upgrade=true && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)

run: init ## setup free-tier eliglible Ubuntu instance, usage: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt run-all validate && terragrunt run-all $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)

ssh: ## ssh to EC2 instance
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make ssh ENV=dev INSTANCE=ubuntu)
endif
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_dns)

ssm-ssh: ## ssh to EC2 instance over SSM SSH
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make ssm-ssh ENV=dev INSTANCE=ubuntu)
endif
	aws ssm start-session --target "$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_id)"

destroy-instance: ## terminate instance
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make destroy-instance ENV=dev INSTANCE=ubuntu)
endif
	aws ec2 terminate-instances --instance-ids "$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_id)"

show-instance-startup-logs: # show EC2 cloud-init startup logs
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make destroy-instance ENV=dev INSTANCE=ubuntu)
endif
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_dns) cat /var/log/cloud-init-output.log

show-instance-startup-script: # show EC2 cloud-init startup script
ifndef INSTANCE
	$(error Env INSTANCE is not defined. Usage make destroy-instance ENV=dev INSTANCE=ubuntu)
endif
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_dns) sudo cat /var/lib/cloud/instance/cloud-config.txt


test: ## test Nginx instance
	curl http://$(shell cd stage/$(ENV)/${INSTANCE} && terragrunt output ec2_dns):80


show-state: ## show state
	cd stage/$(ENV)/${INSTANCE} && terragrunt state list && terragrunt show


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
