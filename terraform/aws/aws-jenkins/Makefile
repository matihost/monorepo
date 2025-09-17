.EXPORT_ALL_VARIABLES:

JENKINS_MASTER_AMI := jenkins-master
JENKISN_AGENT_AMI := jenkins-java-agent


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
REGION := us-east-1

init: prepare
	cd stage/$(ENV) && terragrunt init -upgrade=true --backend-bootstrap --non-interactive


run: init check-master-ami check-agent-ami ## setup Jenkins Master EC2 instance group, usage: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)


JENKINS_INSTANCE_PUBLIC_IP = $(shell aws ec2 describe-instances --filters 'Name=tag:Name,Values=$(ENV)-$(REGION)-jenkins-master' --output json --region $(REGION) | jq -r '.Reservations[].Instances[] | select(.State.Name == "running") | .PublicIpAddress')
ssh: ## ssh to Jenkins EC2 instance
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(JENKINS_INSTANCE_PUBLIC_IP)

show-instance-startup-logs: ## show Jenkins EC2 cloud-init statup logs
	ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@$(JENKINS_INSTANCE_PUBLIC_IP) cat /var/log/cloud-init-output.log

#TODO scale up when old instance state is no more running
recreate-instance: ## recreate Jenkins VM instance to ensure its latest LaunchTemplate is used
	aws autoscaling set-desired-capacity --region $(REGION) --auto-scaling-group-name $(ENV)-$(REGION)-jenkins-master --desired-capacity 0
	sleep 20
	aws autoscaling set-desired-capacity --region $(REGION) --auto-scaling-group-name $(ENV)-$(REGION)-jenkins-master --desired-capacity 1

JENKINS_INSTANCE_URL="http://$(JENKINS_INSTANCE_PUBLIC_IP):8080"
open-jenkins: ## open Jenkins Master instance
	xdg-open $(JENKINS_INSTANCE_URL) || sensible-browser $(JENKINS_INSTANCE_URL) || x-www-browser $(JENKINS_INSTANCE_URL) || gnome-open $(JENKINS_INSTANCE_URL)


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show
	@echo "Jenkins public IP: $(JENKINS_INSTANCE_PUBLIC_IP)"

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

JENKINS_AGENTS=$(shell aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --region $(REGION) --filters "Name=tag:Name,Values=$(ENV)-$(REGION)-jenkins-agent" --output text 2>/dev/null)
destroy-jenkins-agents: ## destroy leftover Jenkins Agents
ifneq ($(JENKINS_AGENTS),)
	aws ec2 terminate-instances --region $(REGION) --instance-ids $(JENKINS_AGENTS)
endif

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.aws.vm; }


check-master-ami:
	@[ -n "`aws ec2 describe-images --region $(REGION)  --owners self --filters "Name=name,Values=$(JENKINS_MASTER_AMI)*" --query 'sort_by(Images, &CreationDate)[].ImageId'`" ] || { echo "Missing Jenkins Master AMI in current AWS account: $(JENKINS_MASTER_AMI), run prerequisites/amis/$(JENKINS_MASTER_AMI) to build AMI first"; exit 1;}

check-agent-ami:
	@[ -n "`aws ec2 describe-images --region $(REGION)  --owners self --filters "Name=name,Values=$(JENKINS_AGENT_AMI)*" --query 'sort_by(Images, &CreationDate)[].ImageId'`" ] || { echo "Missing Jenkins Master AMI in current AWS account: $(JENKINS_AGENT_AMI), run prerequisites/amis/$(JENKINS_AGENT_AMI) to build AMI first"; exit 1;}

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
