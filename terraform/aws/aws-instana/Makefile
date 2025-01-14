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


init:
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init ## setup Instana resources: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)


ssh: ## ssh to AWS Instance Agent EC2 instance over SSM SSH
	aws ssm start-session --target "$(shell cd stage/$(ENV) && terragrunt output agent_ec2_id)"

destroy-instance: ## terminate AWS Instance Agent EC2 instance
	aws ec2 terminate-instances --instance-ids "$(shell cd stage/$(ENV) && terragrunt output agent_ec2_id)"

show-agent-user-data: ## show AWS Instance Agent EC2 user data
	eval "$(shell cd stage/$(ENV) && terragrunt output agent_ec2_user_data)"

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean test
