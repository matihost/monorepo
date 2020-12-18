WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare ## deploy Jenkins EC2 instance and related resources, usage: make apply PASS=passwordForJenkinsMaster
ifndef PASS
	$(error Env PASS is not defined. Provider password for Jenkins admin to provision.)
endif
	@export TF_VAR_external_access_ip=$(WHOAMI) && \
	export TF_VAR_admin_password=$(PASS) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

JENKINS_INSTANCE_PUBLIC_IP = $(shell aws ec2 describe-instances --filters 'Name=tag:Name,Values=jenkins' --output json --region us-east-1 | jq -r '.Reservations[].Instances[] | select(.State.Name == "running") | .PublicIpAddress')
ssh: ## ssh to Jenkins EC2 instance
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(JENKINS_INSTANCE_PUBLIC_IP)

show-instance-startup-logs: ## show Jenkins EC2 cloud-init statup logs
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(JENKINS_INSTANCE_PUBLIC_IP) cat /var/log/cloud-init-output.log

#TODO scale up when old instance state is no more running
recreate-instance: ## recreate Jenkins VM instance to ensure its latest LaunchTemplate is used
	aws autoscaling set-desired-capacity --auto-scaling-group-name jenkins --desired-capacity 0
	sleep 20
	aws autoscaling set-desired-capacity --auto-scaling-group-name jenkins --desired-capacity 1

JENKINS_INSTANCE_URL="http://$(JENKINS_INSTANCE_PUBLIC_IP):8080"
open-jenkins: ## open Jenkins Master instance
	xdg-open $(JENKINS_INSTANCE_URL) || sensible-browser $(JENKINS_INSTANCE_URL) || x-www-browser $(JENKINS_INSTANCE_URL) || gnome-open $(JENKINS_INSTANCE_URL)


show-state: ## show terraform.state
	terraform state list
	terraform show
	@echo "Jenkins public IP: $(JENKINS_INSTANCE_PUBLIC_IP)"

destroy: destroy-jenkins-agents ## terminates all AWS resource created with apply task, it also proactively terminate all EC2 jenkins-agent instances
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform plan && terraform destroy -auto-approve

JENKINS_AGENTS=$(shell aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Name,Values=jenkins-agent" --output text 2>/dev/null)
destroy-jenkins-agents:
ifneq ($(JENKINS_AGENTS),)
	aws ec2 terminate-instances --instance-ids $(JENKINS_AGENTS)
endif


prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.aws.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
