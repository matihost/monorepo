TAG := latest
CURRENT_DIR := $(notdir $(shell pwd))
NAME := $(CURRENT_DIR)
REPO := quay.io/matihost

SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain

build: ## builds docker image
	docker build --load -t $(REPO)/$(NAME):$(TAG) .

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push $(REPO)/$(NAME):$(TAG)

tag: ## tag latest image with additional tag
ifeq ($(TAG),latest)
	$(error TAG cannot be latest)
endif
	docker tag $(REPO)/$(NAME):latest $(REPO)/$(NAME):$(TAG)

run-bash: ## run image with bash
	docker run -it --rm --entrypoint sh $(REPO)/$(NAME):${TAG}


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
