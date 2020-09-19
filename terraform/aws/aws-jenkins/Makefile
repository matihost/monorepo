WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare ## setup free-tier eliglible Ubuntu instance
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

JENKINS_INSTANCE_PUBLIC_IP = $(shell aws ec2 describe-instances --filters 'Name=tag:Name,Values=jenkins' --output json --region us-east-1 | jq -r '.Reservations[].Instances[] | select(.State.Name == "running") | .PublicIpAddress')
ssh: ## ssh to EC2 instance
	ssh -i ~/.ssh/id_rsa.aws.vm ubuntu@$(JENKINS_INSTANCE_PUBLIC_IP)

#TODO scale up when old instance state is no more running
recreate-instance: ## recreate Jenkins VM instance to ensure its latest LaunchTemplate is used
	aws autoscaling set-desired-capacity --auto-scaling-group-name jenkins --desired-capacity 0
	sleep 15
	aws autoscaling set-desired-capacity --auto-scaling-group-name jenkins --desired-capacity 1


test: ## test Jenkins instance
	curl http://$(JENKINS_INSTANCE_PUBLIC_IP):8080

show-state: ## show terraform.state
	terraform state list
	terraform show
	@echo "Jenkins public IP: $(JENKINS_INSTANCE_PUBLIC_IP)"

destroy: ## destroy ec2 instance
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform plan && terraform destroy -auto-approve

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -t rsa -N '' -f id_rsa.aws.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
