BASE := quay.io/matihost/vue
TAG := latest
IMAGE := $(BASE):${TAG}

SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain

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
ifndef VITE_AUTH0_DOMAIN
	$(error Env VITE_AUTH0_DOMAIN is not defined. Usage make run [ENV=dev])
endif
ifndef VITE_AUTH0_CLIENT_ID
	$(error Env VITE_AUTH0_CLIENT_ID is not defined. Usage make run [ENV=dev])
endif
	npm run serve

build: format ## produce production package in build directory
# ifneq ($(strip $(ENV)),prod)
# 	$(error Env ENV has to be prod for build task)
# endif
ifndef VITE_AUTH0_DOMAIN
	$(error Env VITE_AUTH0_DOMAIN is not defined. Usage make run [ENV=dev])
endif
ifndef VITE_AUTH0_CLIENT_ID
	$(error Env VITE_AUTH0_DOMAIN is not defined. Usage make run [ENV=dev])
endif
	npm run build

format: ## run Prettier to format the code
	npm run format

serve: ## run NodeJS server and expose statically dist directory content
ifeq ($(wildcard dist),)
	$(error Directory 'dist' does not exist, ensure make build has be run)
endif
	node web-server.js

build-image: ## builds container image, assumes make build with desired env and other parameters are set
ifeq ($(wildcard dist),)
	$(error Directory 'dist' does not exist, ensure make build has be run)
endif
	docker build --load -t $(IMAGE) .

run-container: ## run container image
	@docker run -p 3000:3000 --init --rm $(IMAGE)

debug-container: ## run shell in the container image
	docker run -it --rm --entrypoint sh $(IMAGE)


clean: ## clean build directory
	rm -rf dist

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run build clean
