TAG := latest
JAVA_VERSION := 21
build: ## builds docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build --build-arg=JAVA_VERSION=$(JAVA_VERSION) -t quay.io/matihost/gh-gcp-java-kaniko:$(TAG) .

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/matihost/gh-gcp-java-kaniko:$(TAG)

tag: ## tag latest image with additional tag
ifeq ($(TAG),latest)
	$(error TAG cannot be latest)
endif
	docker tag quay.io/matihost/gh-gcp-java-kaniko:latest quay.io/matihost/gh-gcp-java-kaniko:$(TAG)

run-bash: ## run image with bash
	docker run -it --rm --entrypoint sh quay.io/matihost/gh-gcp-java-kaniko:${TAG}


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
