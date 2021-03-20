PROJECT := "github.com/matihost/learning"
REPOSITORY := "go"
CMD_PACKAGE_NAME := "language"

DIR := $(shell pwd )

GO_PACKAGE := $(PROJECT)/$(REPOSITORY)

build: ## build all
	go build -mod=mod -o .  ./...

list-dependencies: ## list all modules dependencies including transient ones
	go list -m all

show-dependency-graph: ## show dependency graph
	go mod graph

remove-unused-dependencies: ## remove unused dependencies
	go mod tidy

clean: ## removes compiled application and vendor directory
	@rm -rf ${CMD_PACKAGE_NAME} http-server go.sum vendor

build-image: ## builds docker image
	@DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t $(GO_PACKAGE)/cmd/language:latest .

run-container: ## run docker image
	@docker run -it --rm $(GO_PACKAGE)/cmd/language:latest

module-init:  ## init module
	go mod init $(GO_PACKAGE)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build clean run-container build-image


### Old GOPATH style of building

GOPATH := $(shell go env GOPATH)
TEMP_GO_PATH := ${DIR}/.build-workspace
#TODO  build all packages within 'cmd' package
gopath-build:  ## build app language
	@(ls vendor >/dev/null 2>&1 || ${MAKE} get-dependencies) && \
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	cd cmd/${CMD_PACKAGE_NAME} && \
	go build && \
	mv ${CMD_PACKAGE_NAME} ${DIR} && \
	cd ${DIR} && ${MAKE} test && \
	echo "Application ${CMD_PACKAGE_NAME} has been build"


gopath-test:  ## run go tests
	@cd ${GOPATH}/src/${PROJECT}/${REPOSITORY}/pkg/language && \
	go test

gopath-get-dependencies: gopath-prepare-gopath ## download dependencies to vendor using dep tool
	@cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	(ls Gopkg.toml >/dev/null 2>&1 || dep init) && \
	dep ensure -update

gopath-get-dependencies-to-gopath: ## download dependencies to GOPATH, old style, works when vendor directory is empty
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	go get -v ./...

gopath-prepare-gopath: ## populates GOPATH with this project, removes previous GOPATH reference
	@mkdir -p ${GOPATH}/src/${PROJECT} && \
	cd ${GOPATH}/src/${PROJECT} && \
	(rm -f ${REPOSITORY} && ln -s ${DIR} ${REPOSITORY})
