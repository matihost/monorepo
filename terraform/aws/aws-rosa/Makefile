.EXPORT_ALL_VARIABLES:

RHCS_TOKEN := $(shell rosa token --refresh)

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
	TG_FLAGS := --terragrunt-debug
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	$(error Mode destroy is not supported via task run, to destroy cluster execute explicitly make destroy CLUSTER_NAME=... ENV=... )
else
	MODE_STR := plan
endif


ENV := dev

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init ## setup ROSA : make run [ENV=dev] [MODE=apply]
ifndef PASS
	$(error Env PASS is not defined. Cluster-admin break glass password is needed.)
endif
	cd stage/$(ENV) && { export CLUSTER_ADMIN_PASS=$(PASS);  terragrunt validate && terragrunt --non-interactive $(MODE_STR) $(TG_FLAGS); }

destroy: # destroy cluster, usage: make destroy CLUSTER_NAME=dev-us-east-1 [ENV=dev]
ifndef CLUSTER_NAME
	$(error Env CLUSTER_NAME is not defined. Cluster name is required along with DEV variable)
endif
	rosa delete cluster -c $(CLUSTER_NAME) -w -y
	cd stage/$(ENV) && { terragrunt state rm rhcs_hcp_machine_pool.machine_pool; \
		terragrunt state rm rhcs_hcp_default_ingress.default_ingress; \
		terragrunt --non-interactive destroy -auto-approve $(TG_FLAGS); \
	}


show-state: ## show state
	cd stage/$(ENV) && terragrunt state list && terragrunt show

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init

prerequisites:
	@rosa verify rosa && \
		rosa verify openshift && \
		rosa whoami && \
		rosa verify quota && \
		{ aws iam get-role --role-name "AWSServiceRoleForElasticLoadBalancing" --output text 1>/dev/null || aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"; } \
		|| { echo "Verification failed."; exit 1; }

ensure-proxy-tunnel-open: ##  ensure SSH tunnel is opened to tiny-proxy on bastion node - allowing access to private ROSA cluster endpoints
	cd ../aws-network-setup && $(MAKE) expose_bastion_proxy_locally ENV=$(ENV)

cluster-admin-login: ## login to OCP cluster as break glass cluster-admin, for private cluster you may need to open SSH tunnel to bastion tiny-proxy, aka go to aws-network-setup and run: make expose_bastion_proxy_locally
	export HTTPS_PROXY=http://localhost:8888 && oc login -u cluster-admin $(shell cd stage/$(ENV) && terragrunt output cluster_api_url)


get-web-console-url: ## cluster Web Console URL endpoint
	@echo -n $(shell cd stage/$(ENV) && terragrunt output cluster_console_url)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
