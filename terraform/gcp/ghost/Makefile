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

init:
ifndef ENV
	$(error Environment ENV is not defined. Usage make init ENV=prod [DEBUG=true])
endif
	cd stage/$(ENV)/ghost && terragrunt init -upgrade=true

run-ghost: init ## usage: Usage make run-ghost ENV=prod MODE=plan [DEBUG=true])
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
	cd stage/$(ENV)/ghost && terragrunt validate && terragrunt $(MODE_STR)) --terragrunt-non-interactive $(TG_FLAGS)


run-posts-management: init ## usage: Usage make run-ghost ENV=prod MODE=plan [DEBUG=true])
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
ifndef ADMIN_KEY
	$(error Environment ADMIN_KEY is not defined. See https://ghost.org/docs/admin-api/javascript/#authentication how get one. Usage make run ENV=dev ADMIN_KEY=... CONTENT_KEY=... [MODE=apply] [DEBUG=true])
endif
ifndef CONTENT_KEY
	$(error Environment CONTENT_KEY is not defined. See https://ghost.org/docs/admin-api/javascript/#authentication how get one. Usage make run ENV=dev ADMIN_KEY=... CONTENT_KEY=... [MODE=apply] [DEBUG=true])
endif
	cd stage/$(ENV)/posts-management && terragrunt validate && terragrunt $(MODE_STR)) --terragrunt-non-interactive $(TG_FLAGS)

remove-all-posts: ## delete all posts, usage: make remove-all-posts ENV=dev
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=dev [MODE=apply] [DEBUG=true])
endif
ifndef ADMIN_KEY
	$(error Environment ADMIN_KEY is not defined. See https://ghost.org/docs/admin-api/javascript/#authentication how get one. Usage make run ENV=dev ADMIN_KEY=... CONTENT_KEY=... [MODE=apply] [DEBUG=true])
endif
ifndef CONTENT_KEY
	$(error Environment CONTENT_KEY is not defined. See https://ghost.org/docs/admin-api/javascript/#authentication how get one. Usage make run ENV=dev ADMIN_KEY=... CONTENT_KEY=... [MODE=apply] [DEBUG=true])
endif
	URL="$$(cd stage/$(ENV)/posts-management && terragrunt output -raw removeAllPostsURL 2>/dev/null)" && \
	curl -m 70 -X POST "$${URL}" \
	-H "Authorization: bearer $$(gcloud auth print-identity-token)" \
	-H "Content-Type: application/json" \
	-d '{}'

google-authentication: prepare ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login

clean: ## clean cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +
	find . -name "node_modules" -exec rm -rf {} +

upgrade-providers-version: init
help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run clean
