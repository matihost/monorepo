.EXPORT_ALL_VARIABLES:

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

init:
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=prod MODE=plan [DEBUG=true])
endif
	cd stage/$(ENV)/keycloak && terragrunt init -upgrade=true

run-keycloak: init ## usage: Usage make run-keycloak ENV=prod MODE=plan [DEBUG=true])
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
	cd stage/$(ENV)/keycloak && terragrunt validate && terragrunt $(MODE_STR)


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +
	find . -name "node_modules" -exec rm -rf {} +


TAG := latest
POSTGRESQL_JDBC_VERSION := 1.13.1
KEYCLOAK_METRICS_SPI_VERSION := 4.0.0
CURRENT_PROJECT := $(shell gcloud config get-value project)

configure-docker-registry:
	gcloud auth configure-docker us-central1-docker.pkg.dev

image: ## builds keycloak image with support to PostreSQL GC ClouSQL
	mkdir -p target
	curl -sL https://storage.googleapis.com/cloud-sql-connectors-java/v$(POSTGRESQL_JDBC_VERSION)/postgres-socket-factory-$(POSTGRESQL_JDBC_VERSION)-jar-with-dependencies.jar -o target/postgres-socket-factory-jar-with-dependencies.jar
	curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/$(KEYCLOAK_METRICS_SPI_VERSION)/keycloak-metrics-spi-$(KEYCLOAK_METRICS_SPI_VERSION).jar -o target/keycloak-metrics-spi.jar
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t quay.io/matihost/keycloak-postgres-cloudsql:$(TAG) .
	docker push quay.io/matihost/keycloak-postgres-cloudsql:$(TAG)
	docker tag quay.io/matihost/keycloak-postgres-cloudsql:$(TAG) us-central1-docker.pkg.dev/$(CURRENT_PROJECT)/docker/keycloak-postgres-cloudsql:$(TAG)
	docker push us-central1-docker.pkg.dev/$(CURRENT_PROJECT)/docker/keycloak-postgres-cloudsql:$(TAG)

run-bash: ## run image with bash
	docker run -it --entrypoint bash --rm quay.io/matihost/keycloak-postgres-cloudsql:$(TAG)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
