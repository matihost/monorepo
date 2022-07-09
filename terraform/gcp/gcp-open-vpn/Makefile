.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)

TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_external_access_cidrs := ["$(WHOAMI)/32"]

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif

init-terraform:
	terraform init -upgrade=true

run: init-terraform prepare ## setup Open VPN usage: make run [MODE=apply]
	@terraform validate && \
	terraform $(MODE_STR)

# sample: make run-with-dns-forwarding ZONE=matihost IP=10.8.0.2
run-with-dns-forwarding: init-terraform prepare ## usage: make apply-with-dns-forwarding ZONE=vpnclient.zone.com IP=onpremise_dns_server_ip;  setup Open VPN and forwards DNS to client VPN network DNS nameserver
	@terraform validate && \
	terraform $(MODE_STR) -var='onpremise_dns_zone_forward={"zone":"$(ZONE)","dns_ip":"$(IP)"}'


connect-to-vpn: ## connect to Open VPN peer
	./connect-to-vpn.sh

ssh: ## ssh to OpenVPN instance (via External IP since VPN Gateway has to be exposed via public IP)
	ssh -i ~/.ssh/id_rsa.cloud.vm -o StrictHostKeyChecking=no ubuntu@$(shell terraform output vpn_gateway_external_ip)

show-clouddns-resolvers: ## show CloudDNS resolvers
	gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'

show-state: ## show terraform.state
	terraform state list
	terraform show

clean: ## clean Terraform cached plugins and data
	rm -rf target .terraform* terraform.tfstate*

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run destroy
