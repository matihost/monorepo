.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

APPROVE := true
ifeq ($(strip $(APPROVE)),true)
	APPROVE_STR := -auto-approve
endif


apply: init-terraform prepare-tls ## deploy ApigeeX, usage: make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false]
ifndef EXTERNAL_DNS
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	@terraform validate && \
	terraform plan -lock=false -var='external_dns=$(EXTERNAL_DNS)' && \
	terraform apply $(APPROVE_STR) -var='external_dns=$(EXTERNAL_DNS)'

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy ApigeeX resources
	terraform plan && terraform destroy -auto-approve && \
	rm -rf target

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

init-terraform:
	terraform init -upgrade=true


prepare-tls:
ifndef EXTERNAL_DNS
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	@[ -e "target/$(EXTERNAL_DNS).crt" ] || { mkdir -p target; openssl req -x509 -sha256 -days 365 -subj "/C=PL/ST=ML/L=CityName/O=myorg/OU=Central/CN=$(EXTERNAL_DNS)" -newkey rsa:2048 -nodes -keyout target/$(EXTERNAL_DNS).key -out target/$(EXTERNAL_DNS).crt; }

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* terraform.tfstate*


deploy-exchanges-provider: ## deploys exchange-rate-web app as container on VM (sample Apigee targetServer for exchanges API proxy)
	gcloud compute instances create-with-container exchange-rate-web \
    --container-image quay.io/matihost/exchange-rate:latest --container-restart-policy=always \
    --subnet private-subnet-us-east1 --zone us-east1-b --no-address --metadata enable-oslogin=TRUE \
    --machine-type=e2-micro \
    --image-project=cos-cloud --image-family=cos-stable --boot-disk-size=10GB

destroy-exchanges-provider: ## destroy exchange-rate-web VM
	gcloud compute instances delete exchange-rate-web --zone us-east1-b --quiet

deploy-echoserver: ## deploys exchange-rate-web app as container on VM (sample Apigee targetServer for exchanges API proxy)
	gcloud compute instances create-with-container echoserver-web \
    --container-image k8s.gcr.io/echoserver:1.10 --container-restart-policy=always \
    --subnet private-subnet-us-east1 --zone us-east1-b --no-address --metadata enable-oslogin=TRUE \
    --machine-type=e2-micro \
    --image-project=cos-cloud \
		--image-family=cos-stable --boot-disk-size=10GB

destroy-echoserver: ## destroy exchange-rate-web VM
	gcloud compute instances delete echoserver-web --zone us-east1-b --quiet

deploy-api-proxies: ## deploy all API proxies from proxies directory (exchanges and echoserver) on Apigee
	cd proxies && $(MAKE) deploy-all

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy