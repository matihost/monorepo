.EXPORT_ALL_VARIABLES:

BUILDKIT_PROGRESS=plain
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



init:
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=prod MODE=plan [DEBUG=true])
endif
	cd stage/$(ENV)/keycloak && terragrunt init -upgrade=true

run-keycloak: init ## usage: Usage make run-keycloak ENV=prod MODE=plan [DEBUG=true])
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
	cd stage/$(ENV)/keycloak && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS)


google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean Terraform cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +
	find . -name "node_modules" -exec rm -rf {} +

TAG := latest
POSTGRESQL_JDBC_VERSION := 1.21.2
KEYCLOAK_METRICS_SPI_VERSION := 7.0.0
CURRENT_PROJECT := $(shell gcloud config get-value project 2>/dev/null)

configure-docker-registry:
	gcloud auth configure-docker us-central1-docker.pkg.dev

build-sql-connector: # build https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory a dependency for Keycloak
	mkdir -p target
	curl -sL https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory/archive/refs/tags/v$(POSTGRESQL_JDBC_VERSION).zip -o target/sql.zip
	cd target && unzip sql.zip && \
	  cd cloud-sql-jdbc-socket-factory-$(POSTGRESQL_JDBC_VERSION) && \
	  mvn -P jar-with-dependencies clean package -DskipTests && \
	  mv jdbc/postgres/target/postgres-socket-factory-$(POSTGRESQL_JDBC_VERSION)-jar-with-dependencies.jar ../postgres-socket-factory-jar-with-dependencies.jar && \
	  cd .. && rm -rf sql.zip cloud-sql-jdbc-socket-factory-*

image: build-sql-connector ## builds keycloak image with support to PostreSQL GC ClouSQL
	curl -sL https://github.com/aerogear/keycloak-metrics-spi/releases/download/$(KEYCLOAK_METRICS_SPI_VERSION)/keycloak-metrics-spi-$(KEYCLOAK_METRICS_SPI_VERSION).jar -o target/keycloak-metrics-spi.jar
	docker build --load -t quay.io/matihost/keycloak-postgres-cloudsql:$(TAG) .
	docker push quay.io/matihost/keycloak-postgres-cloudsql:$(TAG)
	docker tag quay.io/matihost/keycloak-postgres-cloudsql:$(TAG) us-central1-docker.pkg.dev/$(CURRENT_PROJECT)/docker/keycloak-postgres-cloudsql:$(TAG)
	docker push us-central1-docker.pkg.dev/$(CURRENT_PROJECT)/docker/keycloak-postgres-cloudsql:$(TAG)

run-bash: ## run image with bash
	docker run -it --entrypoint bash --rm quay.io/matihost/keycloak-postgres-cloudsql:$(TAG)

get-keycloak-gs-bucket: ## get GS bucket
ifndef ENV
	$(error Environment ENV is not defined. Usage make get-keycloak-gs-bucket ENV=prod)
endif
	@echo -n $(shell cd stage/$(ENV)/keycloak && terragrunt output keycloak_gs_bucket)


TLS_MODE := HTTP
ifeq ($(strip $(TLS_MODE)),TXT)
	TLS_AUTHZ_MODE_TXT := --preferred-challenges=dns
endif

generate-letsencrypt-cert: ## generate Let's Encrypt TLS certificate, usage make generate-letsencrypt-cert DOMAIN=id.yourdomain.com [TLS_MODE=TXT]
ifndef DOMAIN
	$(error Env DOMAIN is not defined. Usage make generate-letsencrypt-cert DOMAIN=id.matihost.mooo.com)
endif
	mkdir -p ~/.tls
	sudo certbot certonly --manual $(TLS_AUTHZ_MODE_TXT) -d $(DOMAIN)
	sudo cp -Lr /etc/letsencrypt/live/$(DOMAIN) ~/.tls
	sudo chown -R $(shell whoami):$(shell whoami) ~/.tls
	sudo chmod -R go-rwx ~/.tls


run-keycloak-config: ## configure Keycloak instance; usage: make run-keycloak-config ENV=prod MODE=plan [DEBUG=true] [KEYCLOAK_USER=... KEYCLOAK_PASSWORD=...] [KEYCLOAK_CLIENT_ID=cd KEYCLOAK_CLIENT_SECRET=....]
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=prod MODE=plan [DEBUG=true])
endif
	cd stage/$(ENV)/keycloak-config && terragrunt init -upgrade=true && terragrunt validate && terragrunt $(MODE_STR) --terragrunt-non-interactive $(TG_FLAGS) && terragrunt output -json

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
