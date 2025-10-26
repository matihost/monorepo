TAG := lts

SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain

build: ## builds docker image
	docker build --load -t quay.io/matihost/jenkins:$(TAG) .

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/matihost/jenkins:$(TAG)

tag: ## tag lts image with additional tag
ifeq ($(TAG),lts)
	$(error TAG cannot be lts)
endif
	docker tag quay.io/matihost/jenkins:lts quay.io/matihost/jenkins:$(TAG)

run-bash: ## run image with bash
	docker run -it --rm quay.io/matihost/jenkins:${TAG} bash

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
