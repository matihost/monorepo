SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	DEBUG_MODE :=--terragrunt-log-level debug --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve $(DEBUG_MODE)
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve $(DEBUG_MODE)
else
	MODE_STR := plan $(DEBUG_MODE)
endif


ENV := dev-northeurope

init: init-tf-backend prepare
	cd stage/$(ENV) && terragrunt init -upgrade=true --backend-bootstrap --non-interactive


run: init ## setup VPC: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR)

ssh-via-bastion: ## connect to instance via Azure Bastion
	az network bastion ssh \
		--name $(shell cd stage/$(ENV) && terragrunt output bastion_name)  \
		--resource-group dev \
		--target-resource-id $(shell cd stage/$(ENV) && terragrunt output vm_id) \
		--auth-type ssh-key \
		--username ubuntu \
		--ssh-key ~/.ssh/id_rsa.cloud.vm

expose-direct-proxy-locally: ## expose TinyProxy locally to access resource inside VNet - uses az tunnel (limitations, slow)
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || az network bastion tunnel \
  --name $(shell cd stage/$(ENV) && terragrunt output bastion_name)  \
  --resource-group dev \
  --target-resource-id $(shell cd stage/$(ENV) && terragrunt output vm_id) \
  --resource-port 8888 \
  --port 8888 &

shutdown-local-proxy: ## shutdown tunneled bastion's HTTP proxy
	@-[ "$(shell sudo ss -antl |grep -c 8888)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:8888)
	@-[ "$(shell sudo ss -antl |grep -c 2022)" -eq 0 ] || sudo kill -9 $(shell sudo lsof -t -i:2022)


expose-jump-box-ssh-locally:
	@[ "$(shell sudo ss -antl |grep -c 2022)" -ne 0 ] || az network bastion tunnel \
  --name $(shell cd stage/$(ENV) && terragrunt output bastion_name)  \
  --resource-group dev \
  --target-resource-id $(shell cd stage/$(ENV) && terragrunt output vm_id) \
  --resource-port 22 \
  --port 2022 & \
	sleep 2 # workaround for az tunnel delay when run in background


expose-proxy-via-ssh-locally: expose-jump-box-ssh-locally ## expose TinyProxy locally to access resource inside VNet - uses ssh tunneling (done via az tunnel), needs 2 ports, but more resilient
	@[ "$(shell sudo ss -antl |grep -c 8888)" -ne 0 ] || ssh -o StrictHostKeyChecking=accept-new -f -N -i ~/.ssh/id_rsa.cloud.vm ubuntu@127.0.0.1 -p 2022 -L 8888:127.0.0.1:8888


sshuttle: expose-jump-box-ssh-locally ## create sshuttle VPN via instance to the network where instance is located
	sshuttle --dns -e "ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.cloud.vm" -NHr   "ubuntu@localhost:2022" 10.0.0.0/8

test: ## test connectivity via proxy to vm ngnix
	export http_proxy=http://localhost:8888 && export https_proxy=http://localhost:8888 && curl http://dev-weu-vm

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

init-tf-backend:
	cd stage && ./init_azurerm_tf_backend.sh

whoami: ## show current logon (tenant, subscription, user)
	@az account show

login: ## login to Azure Subscription
	az login

sp-login: ## login to Azure Subscription as Service Principal
ifndef ARM_CLIENT_ID
	$(error Env ARM_CLIENT_ID is not defined)
endif
ifndef ARM_CLIENT_SECRET
	$(error Env ARM_CLIENT_ID is not defined)
endif
ifndef ARM_TENANT_ID
	$(error Env ARM_CLIENT_ID is not defined)
endif
	az login --service-principal -u ARM_CLIENT_ID -p ARM_CLIENT_SECRET --tenant ARM_TENANT_ID

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
