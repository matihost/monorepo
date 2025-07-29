# https://github.com/kubernetes/ingress-nginx?tab=readme-ov-file#supported-versions-table
HELM_CHART_VERSION := 4.12.4

nginx-install: ## install/upgrade NGINX
	helm upgrade --install ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx   --namespace ingress-nginx --create-namespace --values nginx-values.yaml --version $(HELM_CHART_VERSION)

nginx-template: ## to see what is going to be deployed
	helm template  ingress-nginx ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx  --namespace ingress-nginx --create-namespace --values nginx-values.yaml --debug --version $(HELM_CHART_VERSION)

nginx-show-default-values: ## show default values of NGINX helm
	helm show values ingress-nginx   --repo https://kubernetes.github.io/ingress-nginx --version $(HELM_CHART_VERSION)

nginx-show-deployed-resources: ## show deployed resoources
	helm get manifest  ingress-nginx -n ingress-nginx

nginx-show-deployed-all-info: ## show deployed Helm all information
	helm get all  ingress-nginx -n ingress-nginx


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help nginx-install
