SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --inputs-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := --non-interactive -- apply -auto-approve
	K8S_MODE_STR := apply
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := --non-interactive -- destroy -auto-approve
	K8S_MODE_STR := delete
else
	MODE_STR := --non-interactive -- plan
	K8S_MODE_STR := get
endif

PARTITION := aws

ENV := dev

ifeq ($(strip $(PARTITION)),eusc)
	DEPLOY_PATH := stage/eusc/$(ENV)
else
	DEPLOY_PATH := stage/$(ENV)
endif

init:
	cd $(DEPLOY_PATH) && terragrunt run -- init -upgrade=true

run: init ## setup EKS: make run [ENV=dev] [MODE=apply]
	@cd $(DEPLOY_PATH) && terragrunt run validate && terragrunt run $(MODE_STR) $(TG_FLAGS)


kubeconfig: ## generate kubeconfig entry for EKS cluster
	aws eks --region $(shell cd $(DEPLOY_PATH)&& terragrunt output -raw region) update-kubeconfig --name $(shell cd $(DEPLOY_PATH)&& terragrunt output -raw cluster_name)

oidc-test: ## test OIDC setup and provide instructions to update ~/.kube/config to use it
ifndef ISSUER_URL
	$(error Environment ISSUER_URL is not defined. For keycloak it would some some: https://id.yourdomain.com/realms/NAME_OF_REALM)
endif
ifndef CLIENT_ID
	$(error Environment CLIENT_ID is not defined. For keycloak it would be realm oidc Client ID, for example: eks)
endif
ifndef CLIENT_SECRET
	$(error Environment CLIENT_SECRET is not defined. For keycloak it would be realm oidc Client ID credentials secret)
endif
	kubectl oidc-login setup \
		--oidc-issuer-url=$(ISSUER_URL) \
		--oidc-client-id=$(CLIENT_ID) \
		--oidc-client-secret=$(CLIENT_SECRET)

kubeconfig-oidc: kubeconfig ## create ~/.kube/config entry for EKS access (using public API endpoint) with user authentication via OIDC
ifndef ISSUER_URL
	$(error Environment ISSUER_URL is not defined. For keycloak it would some some: https://id.yourdomain.com/realms/NAME_OF_REALM)
endif
ifndef CLIENT_ID
	$(error Environment CLIENT_ID is not defined. For keycloak it would be realm oidc Client ID, for example: eks)
endif
ifndef CLIENT_SECRET
	$(error Environment CLIENT_SECRET is not defined. For keycloak it would be realm oidc Client ID credentials secret)
endif
	kubectl config set-credentials oidc \
			--exec-api-version=client.authentication.k8s.io/v1beta1 \
			--exec-command=kubectl \
			--exec-arg=oidc-login \
			--exec-arg=get-token \
			--exec-arg=--oidc-issuer-url=$(ISSUER_URL) \
			--exec-arg=--oidc-client-id=$(CLIENT_ID) \
			--exec-arg=--oidc-client-secret=$(CLIENT_SECRET)
	kubectl config set-context --current --user=oidc


APP := alb # or efs
K8S_NS := $(if $(filter true,$(strip $(FARGATE))),learning-fargate,learning)
test: ## install test application,  make test [MODE=apply] [FARGATE=true] [APP=alb/efs]
	kubectl $(K8S_MODE_STR) -f test/${APP} -n $(K8S_NS)


list-pod-identity-associations: ## list Pod Identity Associations
	aws eks list-pod-identity-associations --cluster-name $(shell cd $(DEPLOY_PATH)&& terragrunt output -raw cluster_name) --region $(shell cd $(DEPLOY_PATH)&& terragrunt output -raw region)

show-state: ## show state
	cd $(DEPLOY_PATH) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
