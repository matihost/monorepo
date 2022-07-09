.EXPORT_ALL_VARIABLES:

CURRENT_PROJECT := $(shell gcloud config get-value project)

TF_VAR_project := $(CURRENT_PROJECT)

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

show-state: ## show terraform.state
	terraform state list
	terraform show


run: init-terraform prepare-tls ## deploy ApigeeX, usage: make run EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false]
ifndef EXTERNAL_DNS
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	@terraform validate && \
	terraform $(MODE) -var='external_dns=$(EXTERNAL_DNS)'

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: init-terraform ## destroy ApigeeX resources
ifndef EXTERNAL_DNS
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	-cd proxies && $(MAKE) undeploy-all
	terraform plan -var='external_dns=$(EXTERNAL_DNS)' && terraform destroy -auto-approve -var='external_dns=$(EXTERNAL_DNS)' && \
	rm -rf target

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	rm -rf target .terraform* terraform.tfstate*

init-terraform:
	terraform init -upgrade=true

prepare-tls:
ifndef EXTERNAL_DNS
	$(error Env EXTERNAL_DNS is not defined. Usage make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false])
endif
	@[ -e "target/$(EXTERNAL_DNS).crt" ] || { mkdir -p target; openssl req -x509 -sha256 -days 365 -subj "/C=PL/ST=ML/L=CityName/O=myorg/OU=Central/CN=$(EXTERNAL_DNS)" -newkey rsa:2048 -nodes -keyout target/$(EXTERNAL_DNS).key -out target/$(EXTERNAL_DNS).crt; }


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

test-echoserver: ## test echo server API over Apigee
ifndef DNS
	$(error Env DNS is not defined. Usage make apply DNS=api.some.com)
endif
	curl -k https://$(DNS)/echoserver

test-exchangerate: ## test exchange rate API over Apigee (get today USD/PLN fixing pair)
ifndef DNS
	$(error Env DNS is not defined. Usage make apply DNS=api.some.com)
endif
	curl -k https://$(DNS)/exchanges/USD/$(shell date -I)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
