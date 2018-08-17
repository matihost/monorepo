PROJECT := "github.com/matihost/learning"
REPOSITORY := "go"
CMD_PACKAGE_NAME := "language"



DIR := $(shell pwd )
GOPATH := $(shell go env GOPATH)
TEMP_GO_PATH := ${DIR}/.build-workspace

build: prepare-gopath
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY}/cmd/${CMD_PACKAGE_NAME} && \
	(ls vendor 2>/dev/null || go get -v ./...) && \
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo && \
	mv ${CMD_PACKAGE_NAME} ${DIR} && echo OK
	


ensure-dep:
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	dep ensure

// https://golang.org/cmd/go/#hdr-Vendor_Directories how vendor directory works
init-dep: prepare-gopath
	cd ${GOPATH}/src/${PROJECT}/${REPOSITORY} && \
	dep init


clean:
	rm -rf ${DIR}/${CMD_PACKAGE_NAME}


prepare-gopath:
	mkdir -p ${GOPATH}/src/${PROJECT} && \
	cd ${GOPATH}/src/${PROJECT} && \
	(rm -f ${REPOSITORY} && ln -s ${DIR} ${REPOSITORY})


# build independently in temporary Go workspace
# works like https://github.com/cloudflare/hellogopher
# but I found it after i wrote this makefile
build-independently: prepare-independent-workspace build-independently-cmd clean-independent-after
	echo OK

build-independently-cmd:
	export GOPATH=${TEMP_GO_PATH}:${GOPATH} && \
	cd ${TEMP_GO_PATH}/src/${PROJECT}/${REPOSITORY}/cmd/${CMD_PACKAGE_NAME} && \
	(ls vendor 2>/dev/null || go get -v ./...) && \
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo && \
	mv ${CMD_PACKAGE_NAME} ${DIR} 
	

prepare-independent-workspace: clean-independent-before
	mkdir -p ${TEMP_GO_PATH}/src/${PROJECT} && \
	cd ${TEMP_GO_PATH}/src/${PROJECT} && \
	ln -s ${DIR} ${REPOSITORY} 

clean-independent-before clean-independent-after:
	rm -rf ${TEMP_GO_PATH}

build-docker:
	docker build -t github.com/matihost/learning/go/cmd/language:latest .

run-docker:
	docker run -it --rm github.com/matihost/learning/go/cmd/language:latest

build-s2i:
	s2i build . registry.access.redhat.com/devtools/go-toolset-7-rhel7:latest github.com/matihost/learning/go/cmd/language:latest -e IMPORT_URL=github.com/matihost/learning/go -e INSTALL_URL=github.com/matihost/learning/go/cmd/language --loglevel q

.PHONY: build prepare-gopath clean ensure-dep init-dep clean-independent-before clean-independent-after build-s2i run-docker build-docker




