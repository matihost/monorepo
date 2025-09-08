TAG := latest
GROUP := matihost
NAME := gitpod/runner

DOCKERFILE := Dockerfile

ifneq ($(strip $(TAG)),latest)
	DOCKERFILE := Dockerfile.$(TAG)
endif

.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain

build: ## builds docker image
	docker build --load -f $(DOCKERFILE) -t quay.io/$(GROUP)/$(NAME):$(TAG) .

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/$(GROUP)/$(NAME):$(TAG)

tag: ## tag latest image with additional tag
ifeq ($(TAG),latest)
	$(error TAG cannot be latest)
endif
	docker tag quay.io/$(GROUP)/$(NAME):latest quay.io/$(GROUP)/$(NAME):$(TAG)

run-bash: ## run image with bash
	docker run -it --rm quay.io/$(GROUP)/$(NAME):${TAG} bash

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
