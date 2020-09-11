WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)
apply: prepare ## setup free-tier eliglible Ubuntu instances via Launch Template, ASG and attache ALB on it
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

test: ## test ALB Nginx instance
	curl http://$(shell terraform output alb_dns):80

show-auto-scalling-group-state: ## show AutoScalingGroup state(see DesiredCapacity for current amount of instances)
	aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver

scale-up-manually: ## scale Auto Scaling Group up by single instance
	aws autoscaling set-desired-capacity --auto-scaling-group-name webserver --desired-capacity $$(( `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver | jq  '..|.DesiredCapacity?'|grep -v null` + 1 ))

scale-down-manually: ## scale Auto Scaling Group down by single instance
	aws autoscaling set-desired-capacity --auto-scaling-group-name webserver --desired-capacity $$(( `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver | jq  '..|.DesiredCapacity?'|grep -v null` - 1 ))


show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy resourced created via apply
	export TF_VAR_external_access_ip=$(WHOAMI) && \
	terraform plan && terraform destroy -auto-approve

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -t rsa -N '' -f id_rsa.aws.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
