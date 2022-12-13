.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)
WHOAMI := $(shell dig +short myip.opendns.com @resolver1.opendns.com)


BIGQUERY_METERING := false
ENCRYPT_ETCD := false
ENABLE_PSP := false
MASTER_PUBLIC_IP := true
MASTER_CIDR := 172.16.0.32/28
MASTER_ACCESS_CIRDS := ["$(WHOAMI)/32"]

TF_VAR_master_cidr = $(MASTER_CIDR)
TF_VAR_external_access_cidrs := $(MASTER_ACCESS_CIRDS)
TF_VAR_expose_master_via_external_ip := $(MASTER_PUBLIC_IP)

TF_VAR_project := $(CURRENT_PROJECT)
TF_VAR_encrypt_etcd := $(ENCRYPT_ETCD)
TF_VAR_bigquery_metering := $(BIGQUERY_METERING)
TF_VAR_enable_pod_security_policy := $(ENABLE_PSP)
TF_VAR_cluster_name := $(CLUSTER_NAME)
TF_VAR_region := $(REGION)
TF_VAR_zone_letter := $(ZONE_LETTER)

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

ensure-cluster-shared1: ## create/update cluster shared1-dev in us-central1-a
	CLUSTER_NAME=shared1 MASTER_CIDR=172.16.0.32/28 REGION=us-central1 ZONE_LETTER=a $(MAKE) run && \
	cd cluster-config && $(MAKE) run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a

ensure-cluster-shared2: ## create/update cluster shared2-dev in us-east1-b
	CLUSTER_NAME=shared2 MASTER_CIDR=172.16.0.64/28 REGION=us-east1 ZONE_LETTER=b $(MAKE) run && \
	cd cluster-config && $(MAKE) run CLUSTER_NAME=shared2 REGION=us-east1 ZONE_LETTER=b

destroy-cluster-shared1: ## destroy cluster shared1-dev in us-central1-a
	cd cluster-config && $(MAKE) run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a MODE=destroy
	CLUSTER_NAME=shared1 MASTER_CIDR=172.16.0.32/28 REGION=us-central1 ZONE_LETTER=a $(MAKE) run MODE=destroy


destroy-cluster-shared2: ## destroy cluster shared2-dev in us-east1-b
	@-terraform workspace new shared2@$(CURRENT_PROJECT) &>/dev/null
	terraform workspace select shared2@$(CURRENT_PROJECT) && \
	cd cluster-config && $(MAKE) run MODE=destroy REGION=us-east1 ZONE_LETTER=b MODE=destroy
	$(MAKE) destroy CLUSTER_NAME=shared2 MASTER_CIDR=172.16.0.64/28 REGION=us-east1 ZONE_LETTER=b

scale-down-shared1: ## scale down to 0 nodes cluster shared1-dev in us-central1-a
	gcloud container clusters resize shared1-dev --zone=us-central1-a --num-nodes=0 --async --quiet

scale-down-shared2: ## scale down to 0 nodes cluster shared2-dev in us-east1-b
	gcloud container clusters resize shared2-dev --zone=us-east1-b --num-nodes=0 --async --quiet

scale-up-shared1: ## scale up to 1 nodes cluster shared1-dev in us-central1-a
	gcloud container clusters resize shared1-dev --zone=us-central1-a --num-nodes=1 --async --quiet

scale-up-shared2:  ## scale up to 1 node cluster shared2-dev in us-east1-b
	gcloud container clusters resize shared2-dev --zone=us-east1-b --num-nodes=1 --async --quiet

run: pre-all ## setup GKE cluster
	@terraform validate && \
	terraform $(MODE_STR) && \
	[ -n "$(MASTER_ACCESS_CIRDS)" ] && \
    gcloud container clusters get-credentials $(CLUSTER_NAME)-dev --zone $(REGION)-$(ZONE_LETTER) || \
    echo "Run 'source access-gke.sh' to setup GKE access for kubectl etc. commands in current shell";

open-tunnel: ## opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
	-@kill `pgrep -a ssh | grep private-dev-bastion | cut -f1 -d' '`
	gcloud compute ssh private-vpc-bastion -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8888:127.0.0.1:8888 -f sleep 36000

setup-kubecontext: pre-all ## creates ~/.kube/config context to for GKE cluster
	gcloud container clusters get-credentials $(CLUSTER_NAME)-dev --zone $(REGION)-$(ZONE_LETTER)

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: init-terraform ## destroy GKE resources
	terraform destroy $(APPROVE_STR)

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate* target

init-terraform:
	terraform init -upgrade=true

pre-all: init-terraform
ifndef CLUSTER_NAME
	$(error Env CLUSTER_NAME is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a [MODE=apply])
endif
ifndef REGION
	$(error Env REGION is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a)
endif
ifndef ZONE_LETTER
	$(error Env ZONE_LETTER is not defined. Usage make run CLUSTER_NAME=shared1 REGION=us-central1 ZONE_LETTER=a)
endif
	-@terraform workspace new $(CLUSTER_NAME)@$(CURRENT_PROJECT) &>/dev/null
	terraform workspace select $(CLUSTER_NAME)@$(CURRENT_PROJECT)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
