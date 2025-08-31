.EXPORT_ALL_VARIABLES:

prerequisites:
ifndef ENV
	$(error Env ENV is not defined.)
endif

deploy-via-helm: prerequisites ## deploys app via Helm
	cd stage/$(ENV) && $(MAKE) deploy-via-helm

deploy-via-script: prerequisites ## deploys app via custom script
	cd stage/$(ENV) && $(MAKE) deploy-via-script

deploy-via-argocd: prerequisites ## deploy app via ArgoCD Application
	cd stage/$(ENV) && $(MAKE) deploy-via-argocd

test: prerequisites ## test e2e app
	cd stage/$(ENV) && $(MAKE) test

uninstall-helm: ## uninstall application via Helm
	cd stage/$(ENV) && $(MAKE) uninstall-helm

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help
