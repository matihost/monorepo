.EXPORT_ALL_VARIABLES:

init: ## install dependencies
	. ${NVM_DIR}/nvm.sh && nvm install --latest-npm && \
		npm install -g serve npm-check-updates && \
		npm install

update: ## update dependencies
	ncu -u
	npm install

ENV := dev
REACT_APP_ENV := $(ENV)

run: ## run locally
ifndef REACT_APP_OIDC_ISSUER
	$(error Env REACT_APP_OIDC_ISSUER is not defined.)
endif
ifndef REACT_APP_OIDC_CLIENT_ID
	$(error Env REACT_APP_OIDC_CLIENT_ID is not defined.)
endif
	npm start

build: ## produce production package in build directory
# ifneq ($(strip $(ENV)),prod)
# 	$(error Env ENV has to be prod for build task)
# endif
ifndef REACT_APP_OIDC_ISSUER
	$(error Env REACT_APP_OIDC_ISSUER is not defined.)
endif
ifndef REACT_APP_OIDC_CLIENT_ID
	$(error Env REACT_APP_OIDC_CLIENT_ID is not defined.)
endif
	npm run build

serve: ## run serve NodeJS server and expose statically build directory content
	serve -s build


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run build
