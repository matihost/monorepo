BASE_OS?=ubuntu
ifeq ($(BASE_OS),original)
IMAGE := quay.io/buildah/stable
else
IMAGE=buildah:$(BASE_OS)
endif


build: ## build buildah builder image base
	buildah bud -t buildah:$(BASE_OS) --format docker -f Dockerfile.priviledged.$(BASE_OS) .
	buildah push localhost/buildah:$(BASE_OS) docker-daemon:buildah:$(BASE_OS)

build-useronly: ## build buildah builder assuming running from non-root (not working yet)
	buildah bud -t buildah-user:$(BASE_OS) --format docker -f Dockerfile.user.$(BASE_OS) .
	buildah push localhost/buildah-user:$(BASE_OS) docker-daemon:buildah-user:$(BASE_OS)

run: ## run buildah container
	podman run -it --rm buildah:$(BASE_OS) /bin/bash

run-user: ## run buildah container as user (does no work)
	podman run -it --rm buildah-user:$(BASE_OS) /bin/bash


docher-run: ## run buildah from official image
	mkdir -p /tmp/buildah
	docker run --security-opt seccomp:unconfined -it --device /dev/fuse:rw -v /tmp/buildah:/var/lib/buildah:Z quay.io/buildah/stable

test-build-image: # build sample image with VFS as storage driver
	echo -e "FROM mirror.gcr.io/library/centos\nRUN echo test" | buildah bud -f - --storage-driver vfs -t alamakota .




deploy: ## deploy buildah pod
	IMAGE=$(IMAGE) eval "echo \"`cat pod.manifest.yaml`\"" | kubectl apply -f -

un-deploy: ## un-deploy base pod
	IMAGE=$(IMAGE) eval "echo \"`cat pod.manifest.yaml`\"" | kubectl delete -f -



help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help
