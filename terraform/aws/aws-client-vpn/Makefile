SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif

ENV := dev

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true --backend-bootstrap --non-interactive


run: init ## setup Client VPN: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)

open-webconsole: ## open ARO web console
	ARO_CONSOLE_URL="$(shell cd stage/$(ENV) && terragrunt output -raw console_url 2>/dev/null)" && \
	xdg-open "$${ARO_CONSOLE_URL}" || sensible-browser "$${ARO_CONSOLE_URL}" || x-www-browser "$${ARO_CONSOLE_URL}" || gnome-open "$${ARO_CONSOLE_URL}"



get-client-ovpn: ## create target/client.ovpn file needed to connect to VPN
	mkdir -p target && cd target && \
	REGION="$(shell cd stage/$(ENV) && terragrunt output -raw region 2>/dev/null)" && \
	CLIENT_VPN_ENDPOINT_ID="$(shell cd stage/$(ENV) && terragrunt output -raw client_vpn_endpoint_id 2>/dev/null)" && \
	aws ec2 export-client-vpn-client-configuration --output text \
    --region "$${REGION}" \
    --client-vpn-endpoint-id "$${CLIENT_VPN_ENDPOINT_ID}" > client.ovpn
	cd stage/$(ENV) && \
		terragrunt output -raw client-ovpn-extension-config 2>/dev/null >> ../../target/client.ovpn

connect-to-vpn: get-client-ovpn ## connect to Open VPN peer
	@echo "OpenVPN client with mode: $(VPN_MODE) will start 'tun' interface and connect to VPN. To stop press Ctrl + C" && \
	sudo openvpn "target/client.ovpn"


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

whoami: ## show current user IAM ID
	aws sts get-caller-identity

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
