build: ## builds docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t quay.io/matihost/ansible:latest .

push: ## push image to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/matihost/ansible:latest

run-bash: ## run image with bash
	docker run -it --rm quay.io/matihost/ansible:latest bash

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help build
