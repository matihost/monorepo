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


init-terraform:
	cd stage/current && terragrunt init -upgrade=true

run: init-terraform ## usage: Usage make run MODE=plan [DEBUG=true])
	cd stage/current && terragrunt validate && terragrunt $(MODE_STR)

show-state: ## show state
	cd stage/current && terragrunt state list && terragrunt show

# destroy task likely not needed
# removal of IAM resource will effectively make users unable to do nothing
# and root accout login would be required to fix issues.

# destroy: ## destroy IAM resources
# 	export TF_PLUGIN_CACHE_DIR=$(HOME)/.cache/terraform/plugins && \
# 	export TF_VAR_external_access_ip=$(WHOAMI) && \
# 	terraform plan && terraform destroy -auto-approve


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destro
