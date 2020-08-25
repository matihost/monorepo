WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare shutdown_local_bastion_proxy ## setup minimal AWS setup, bastion, nas, private network and webservr in private network
	export TF_PLUGIN_CACHE_DIR=$(HOME)/.cache/terraform/plugins && \
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan && \
	terraform apply -auto-approve

show-state: ## show terraform.state
	terraform state list
	terraform show
	aws ec2 describe-instance-attribute --instance-id $(shell terraform output bastion_id) --attribute userData --output text --query "UserData.Value"

bastion-ssh: ## ssh to bastion EC2 instance
	eval "$(shell terraform output bastion_ssh)"

nat-ssh: ## ssh to NAT instance
	eval "$(shell terraform output nat_ssh)"

expose_bastion_proxy_locally: ## expose bastion's HTTP proxy locally
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || eval "$(shell terraform output expose_bastion_proxy_locally)"

shutdown_local_bastion_proxy: ## shutdown tunneled bastion's HTTP proxy
	@[ "$(shell sudo ss -antl |grep -c 8888)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:8888)

test: expose_bastion_proxy_locally ## test private  webeserver
	eval "$(shell terraform output connect_via_bastion_proxy)"

destroy: shutdown_local_bastion_proxy ## destroy applied setup
	export TF_PLUGIN_CACHE_DIR=$(HOME)/.cache/terraform/plugins && \
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform plan && terraform destroy -auto-approve

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -t rsa -N '' -f id_rsa.aws.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
