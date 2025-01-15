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
	cd stage/$(ENV) && terragrunt init -upgrade=true

run: init ## setup ApigeeX: make run [ENV=dev] [MODE=apply]
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)

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
    --container-image registry.k8s.io/echoserver:1.10 --container-restart-policy=always \
    --subnet private-subnet-us-east1 --zone us-east1-b --no-address --metadata enable-oslogin=TRUE \
    --machine-type=e2-micro \
    --image-project=cos-cloud \
		--image-family=cos-stable --boot-disk-size=10GB

destroy-echoserver: ## destroy exchange-rate-web VM
	gcloud compute instances delete echoserver-web --zone us-east1-b --quiet

deploy-api-proxies: ## deploy all API proxies from proxies directory (exchanges and echoserver) on Apigee
	cd proxies && $(MAKE) deploy-all

undeploy-api-proxies: ## undeploy all API proxies from proxies directory (exchanges and echoserver) on Apigee
	cd proxies && $(MAKE) undeploy-all

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

show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
