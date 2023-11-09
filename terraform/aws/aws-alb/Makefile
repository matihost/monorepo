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


ENV := dev

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)


test: ## test ALB Nginx instance
	curl http://$(shell cd stage/$(ENV) && terragrunt output alb_dns):80

show-auto-scalling-group-state: ## show AutoScalingGroup state(see DesiredCapacity for current amount of instances)
	aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver

scale-up-manually: ## scale Auto Scaling Group up by single instance
	aws autoscaling set-desired-capacity --auto-scaling-group-name webserver --desired-capacity $$(( `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver | jq  '..|.DesiredCapacity?'|grep -v null` + 1 ))

scale-down-manually: ## scale Auto Scaling Group down by single instance
	aws autoscaling set-desired-capacity --auto-scaling-group-name webserver --desired-capacity $$(( `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name webserver | jq  '..|.DesiredCapacity?'|grep -v null` - 1 ))


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
