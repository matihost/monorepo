SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

init: ## install dependencies
	. ${NVM_DIR}/nvm.sh && nvm install --latest-npm && \
		npm install -g serve npm-check-updates && \
		npm install

update: ## update dependencies
	ncu -u
	npm install

ENV := dev
VUE_APP_ENV := $(ENV)

run: ## run locally
ifndef VUE_APP_AUTH0_DOMAIN
	$(error Env VUE_APP_AUTH0_DOMAIN is not defined. Usage make run [ENV=dev])
endif
ifndef VUE_APP_AUTH0_CLIENT_ID
	$(error Env VUE_APP_AUTH0_CLIENT_ID is not defined. Usage make run [ENV=dev])
endif
	npm run serve

build: format ## produce production package in build directory
# ifneq ($(strip $(ENV)),prod)
# 	$(error Env ENV has to be prod for build task)
# endif
ifndef VUE_APP_AUTH0_DOMAIN
	$(error Env VUE_APP_AUTH0_DOMAIN is not defined. Usage make run [ENV=dev])
endif
ifndef VUE_APP_AUTH0_CLIENT_ID
	$(error Env VUE_APP_AUTH0_CLIENT_ID is not defined. Usage make run [ENV=dev])
endif
	npm run build

format: ## run Prettier to format the code
	npm run format

serve: ## run serve NodeJS server and expose statically dist directory content
	serve -s dist

clean: ## clean build directory
	rm -rf dist

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run build
