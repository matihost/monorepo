BASE_OS?=ubuntu

build: ## build buildah builder image base
	buildah bud -t buildah:$(BASE_OS) --format docker -f Dockerfile.priviledged.$(BASE_OS) .

build-useronly: ## build buildah builder image full
	buildah bud -t buildah:$(BASE_OS) --format docker -f Dockerfile.user.$(BASE_OS) .

run: ## run buildah container
	podman run -it --rm buildah:$(BASE_OS) /bin/bash

run-user: ## run buildah container
	podman run -it --rm buildah-user:$(BASE_OS) /bin/bash

deploy: ## deploy base container
	BASE_OS=$(BASE_OS) eval "echo \"`cat pod.manifest.yaml`\"" | kubectl apply -f -

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help