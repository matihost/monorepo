PROJECT := "github.com/matihost/learning"
REPOSITORY := "go"
CMD_PACKAGE_NAME := "grpc-client"

GO_PACKAGE := $(PROJECT)/$(REPOSITORY)

build: ## build grpc-client app docker image
	@DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t $(GO_PACKAGE)/$(CMD_PACKAGE_NAME):latest -f Dockerfile ../..

run-client: ## run grpc-client app docker container again grpc-server running locally
	docker run --network host --rm $(GO_PACKAGE)/$(CMD_PACKAGE_NAME):latest -addr localhost:6565 -repeat 3

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build run-client
