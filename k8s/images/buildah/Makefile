# Operating system of the image, ubuntu or centos
BASE_OS ?= ubuntu
ifeq ($(BASE_OS),ubuntu)
	BASE_IMAGE := ubuntu:26.04
else ifeq ($(BASE_OS),centos)
	BASE_IMAGE := quay.io/centos/centos:stream10
else ifneq ($(BASE_OS),original)
$(error BASE_OS has to be one of: ubuntu, centos, original)
endif

TAG ?= $(BASE_OS)
REPO := quay.io/matihost
NAME := buildah
ifeq ($(BASE_OS),original)
	IMAGE := quay.io/buildah/stable
else
	IMAGE := $(REPO)/$(NAME):$(TAG)
endif

SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
BUILDKIT_PROGRESS=plain

build: ## builds docker image on top of selected OS: make build [BASE_OS=ubuntu|centos]
	@[ "$(BASE_OS)" != original ] || { echo "BASE_OS=original is the official image, nothing to build"; exit 1; }
	docker build --load --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(IMAGE) .

push: ## push image to quay.io repository (assume docker login quay.io has been performed)
	@[ "$(BASE_OS)" != original ] || { echo "BASE_OS=original is the official image, nothing to push"; exit 1; }
	docker push $(IMAGE)

run: ## run buildah image with bash, buildah container needs /dev/fuse and relaxed seccomp to build images
	docker run -it --rm --security-opt seccomp=unconfined --security-opt apparmor=unconfined --device /dev/fuse $(IMAGE) bash

test-build-image: ## build sample image inside of the container to verify the image works
	docker run --rm --security-opt seccomp=unconfined --security-opt apparmor=unconfined --device /dev/fuse $(IMAGE) bash -c \
	  'printf "FROM docker.io/library/alpine\nRUN echo test\n" > /tmp/Containerfile && buildah bud -t localhost/test /tmp'

deploy: ## deploy buildah pod to current Kubernetes context, BASE_OS=original deploys quay.io/buildah/stable
	IMAGE=$(IMAGE) envsubst '$${IMAGE}' < pod.manifest.yaml | kubectl apply -f -

un-deploy: ## un-deploy buildah pod
	IMAGE=$(IMAGE) envsubst '$${IMAGE}' < pod.manifest.yaml | kubectl delete -f -

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build push run test-build-image deploy un-deploy
