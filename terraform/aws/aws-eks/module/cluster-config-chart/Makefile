deploy: ## deploy EKS configuration
	helm upgrade --install cluster-config --namespace=cluster-config --create-namespace .

undeploy: ## undeploys EKS configuration
	helm uninstall cluster-config --namespace=cluster-config

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: deploy undeploy
