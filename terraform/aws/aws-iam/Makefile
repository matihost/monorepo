WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare ## setup IAM resources
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve


show-state: ## show terraform.state
	terraform state list
	terraform show

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
.PHONY: help apply destroy
