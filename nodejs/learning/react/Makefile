SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

init: ## install dependencies
	. ${NVM_DIR}/nvm.sh && nvm install --latest-npm && \
		npm install -g npm-check-updates && \
		npm install

update: ## update dependencies
	ncu -u
	npm install

ENV := dev
VITE_ENV := $(ENV)

run: ## run locally
ifndef VITE_OIDC_ISSUER
	$(error Env VITE_OIDC_ISSUER is not defined.)
endif
ifndef VITE_OIDC_CLIENT_ID
	$(error Env VITE_OIDC_CLIENT_ID is not defined.)
endif
	npm start

build: format ## produce production package in dist directory
# ifneq ($(strip $(ENV)),prod)
# 	$(error Env ENV has to be prod for build task)
# endif
ifndef VITE_OIDC_ISSUER
	$(error Env VITE_OIDC_ISSUER is not defined.)
endif
ifndef VITE_OIDC_CLIENT_ID
	$(error Env VITE_OIDC_CLIENT_ID is not defined.)
endif
	npm run build

format: ## run Prettier to format the code
	npm run format

serve: ## serve statically dist directory content (vite preview), dist has to be built with the same VITE_* env variables
ifeq ($(wildcard dist),)
	$(error Directory 'dist' does not exist, ensure make build has be run)
endif
	@# VITE_* variables are inlined into dist during make build, warn when dist was built with another OIDC issuer
	@[ -z "$(VITE_OIDC_ISSUER)" ] || grep -rqF -- "$(VITE_OIDC_ISSUER)" dist/assets || \
		echo "WARNING: dist does not contain VITE_OIDC_ISSUER=$(VITE_OIDC_ISSUER), it was built with other VITE_* values. Run make build first." >&2
	npm run preview

clean: ## clean dist directory
	rm -rf dist

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help init update run build format serve clean
