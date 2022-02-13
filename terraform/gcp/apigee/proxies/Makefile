TOKEN := $(shell gcloud auth print-access-token)
APIGEE_ENV := dev
APIGEE_ORG := $(shell gcloud config get-value project)

PROXY := $(shell find src -mindepth 1 -maxdepth 1 -type d | sed  's/src\///')
${PROXY}: ## deploys ProxyDir
	./uploadApiProxy.py -n $@  -e $(APIGEE_ENV) -t "$(TOKEN)" -o $(APIGEE_ORG) -d src/$@
	gcloud apigee apis deploy --environment=$(APIGEE_ENV) --api=$@ --override

undeploy: ## undeploys proxy; usage make undeploy PROXY=proxyName
ifndef PROXY
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	gcloud apigee apis undeploy --environment=$(APIGEE_ENV) --api=$(PROXY)

deploy-all: ## deploys all proxies from src directory
	for i in $(PROXY); do \
	  $(MAKE) $$i; \
	done

undeploy-all: ## deploys all proxies from src directory
	for i in $(PROXY); do \
	  $(MAKE) undeploy PROXY="$${i}"; \
	done

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help
