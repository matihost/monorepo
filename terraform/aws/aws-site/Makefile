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


test-site:  ## test S3 site URL
	curl -sL $(shell cd stage/$(ENV) && terragrunt output s3_site_url)

test-s3: ## test S3 URL
	curl -sLk $(shell cd stage/$(ENV) && terragrunt output s3_url)/index.html


get-cname-target: ## show domain which should be targeted with CNAME
	@echo -n $(shell cd stage/$(ENV) && terragrunt output s3_site_url) | sed -E 's/.*\/\/(.+)/\1/'

check-dns: ## check whether public resolvers correctly resolves your DNS
ifndef DOMAIN
	$(error Env DOMAIN is not defined. Usage make check-dns DOMAIN=matihost.mooo.com)
endif
	while true; do nslookup $(DOMAIN) 1.1.1.1; echo "Press [CTRL+C] to stop.."; sleep 5; done

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
