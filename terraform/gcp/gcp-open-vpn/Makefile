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

init: prepare
	cd stage/$(ENV) && terragrunt init -upgrade=true

run: init ## setup OpenVPN server: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --non-interactive $(TG_FLAGS)

VPN_MODE := all # or vpc
get-client-ovpn: ## create target/client.ovpn file needed to connect to VPN
	mkdir -p target
	cd stage/$(ENV) && terragrunt output -raw client-ovpn-$(VPN_MODE) 2>/dev/null > ../../target/client.ovpn

connect-to-vpn: get-client-ovpn ## connect to Open VPN peer
	@echo "OpenVPN client with mode: $(VPN_MODE) will start 'tun' interface and connect to VPN. To stop press Ctrl + C" && \
	sudo openvpn "target/client.ovpn"

destroy-vpn: ## destroys VPN gateway instance
	gcloud compute instances delete "$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-name 2>/dev/null)" --zone="$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-zone 2>/dev/null)" --quiet

ssh: ## ssh to OpenVPN instance via IAP
	gcloud compute ssh "$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-name 2>/dev/null)" --tunnel-through-iap --zone="$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-zone 2>/dev/null)"

ssh-over-public-ip: ## ssh to OpenVPN instance via External IP (requires - explicit opening ssh port on VPN firewall)
	ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=no ubuntu@$(shell cd stage/$(ENV) && terragrunt output -raw vpn_gateway_external_ip 2>/dev/null)

check-vpn-service-status: ## check Systemd openvpn-server@server.service status on OpenVPN instance
	gcloud compute ssh "$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-name 2>/dev/null)" --tunnel-through-iap --zone="$(shell cd stage/$(ENV) && terragrunt output -raw vpn-vm-zone 2>/dev/null)" -- sudo systemctl status openvpn-server@server.service

show-clouddns-resolvers: ## show CloudDNS resolvers
	gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	rm -rf target
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
