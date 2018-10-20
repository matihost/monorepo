PROJECT := "github.com/matihost/learning"
REPOSITORY := "go"
CMD_PACKAGE_NAME := "language"

DIR := $(shell pwd )
GOPATH := $(shell go env GOPATH)
TEMP_GO_PATH := ${DIR}/.build-workspace

#TODO  build all packages within 'cmd' package
build:  ## build app language
	@(ls vendor >/dev/null 2>&1 || ${MAKE} get-dependencies) && \
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	cd cmd/${CMD_PACKAGE_NAME} && \
	go build && \
	mv ${CMD_PACKAGE_NAME} ${DIR} && \
	echo "Application ${CMD_PACKAGE_NAME} has been build"

get-dependencies: prepare-gopath ## download dependencies to vendor using dep tool
	@cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	(ls Gopkg.toml >/dev/null 2>&1 || dep init) && \
	dep ensure -update

get-dependencies-to-gopath: ## download dependencies to GOPATH, old style, works when vendor directory is empty
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	go get -v ./...	

clean: ## removes compiled application and vendor directory
	@rm -rf ${DIR}/${CMD_PACKAGE_NAME} && rm -rf vendor

prepare-gopath: ## populates GOPATH with this project, removes previous GOPATH reference
	@mkdir -p ${GOPATH}/src/${PROJECT} && \
	cd ${GOPATH}/src/${PROJECT} && \
	(rm -f ${REPOSITORY} && ln -s ${DIR} ${REPOSITORY})

build-docker: ## builds docker image
	@docker build -t github.com/matihost/learning/go/cmd/language:latest .

run-docker: ## run previous docker image
	@docker run -it --rm github.com/matihost/learning/go/cmd/language:latest

build-s2i: ## builds docker using s2i tooling
	@s2i build . registry.access.redhat.com/devtools/go-toolset-7-rhel7:latest github.com/matihost/learning/go/cmd/language:latest -e IMPORT_URL=github.com/matihost/learning/go -e INSTALL_URL=github.com/matihost/learning/go/cmd/language --loglevel 5 -c

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build prepare-gopath clean ensure-dep init-dep clean-independent-before clean-independent-after build-s2i run-docker build-docker




