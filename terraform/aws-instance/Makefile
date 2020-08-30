WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare ## setup free-tier eliglible Ubuntu instance
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

ssh: ## ssh to EC2 instance
	eval "$(shell terraform output ec2_ssh)"

test: ## test Nginx instance
	curl http://$(shell terraform output ec2_dns):80

show-state: ## show terraform.state
	terraform state list
	terraform show
	eval "$(shell terraform output ec2_user_data)"

destroy: ## destroy ec2 instance
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform plan && terraform destroy -auto-approve

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -t rsa -N '' -f id_rsa.aws.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
