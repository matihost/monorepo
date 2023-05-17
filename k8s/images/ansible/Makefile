TAG := latest
ifeq ($(TAG),latest)
	ROOT_TAG := root
else
	ROOT_TAG := $(TAG)-root
endif

build: ## builds docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t quay.io/matihost/ansible:$(TAG) .
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -f Dockerfile.root -t quay.io/matihost/ansible:$(ROOT_TAG) .

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/matihost/ansible:$(TAG)
	docker push quay.io/matihost/ansible:$(ROOT_TAG)

tag: ## tag latest image with additional tag
ifeq ($(TAG),latest)
	$(error TAG cannot be latest)
endif
	docker tag quay.io/matihost/ansible:latest quay.io/matihost/ansible:$(TAG)
	docker tag quay.io/matihost/ansible:root quay.io/matihost/ansible:$(ROOT_TAG)

run-bash: ## run image with bash
	docker run -it --rm quay.io/matihost/ansible:${TAG} bash

run-root-bash: ## run image with root uid with bash
	docker run -it --rm quay.io/matihost/ansible:${ROOT_TAG} bash

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
