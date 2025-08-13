# https://github.com/bitnami/charts/blob/main/bitnami/mongodb/README.md
HELM_CHART_VERSION := 16.5.36
DEPLOYMENT_NAME := sample-mongodb
NS := learning
VALUES := mongodb-values.yaml

init: ## add bitnami repo to helm
	helm repo add bitnami https://charts.bitnami.com/bitnami

update-repo: ## update repo, show current latest version of the chart
	helm repo update
	helm search repo bitnami/mongodb

mongodb-install: ## install/upgrade MongoDB
	helm upgrade --install $(DEPLOYMENT_NAME) bitnami/mongodb --namespace $(NS) --create-namespace --values $(VALUES) --version $(HELM_CHART_VERSION) --debug

mongodb-uninstall: ## install MongoDB
	helm uninstall $(DEPLOYMENT_NAME) -n $(NS)

get-mongodb-pods: ## get Pods for MongoDB
	kubectl get pods -l app.kubernetes.io/instance=$(DEPLOYMENT_NAME) -n $(NS)

mongosh: ## shell to MongoDB boomerang database
	kubectl -n $(NS) exec -it $(shell kubectl get pods -l app.kubernetes.io/instance=$(DEPLOYMENT_NAME) -n $(NS) --no-headers -o custom-columns=":metadata.name" | head -n 1) -- mongosh --username boomerang --password $(shell kubectl get secret --namespace $(NS) $(DEPLOYMENT_NAME) -o jsonpath="{.data.mongodb-passwords}" | base64 -d | awk -F',' '{print $1}') --authenticationDatabase boomerang --host 127.0.0.1 --port 27017

mongodb-template: ## to see what is going to be deployed
	helm template $(DEPLOYMENT_NAME) bitnami/mongodb --namespace $(NS) --create-namespace --values $(VALUES) --version $(HELM_CHART_VERSION) --debug

mongodb-show-default-values: ## show default values of MongoDB helm
	@helm show values bitnami/mongodb --version $(HELM_CHART_VERSION)

mongodb-show-deployed-resources: ## show deployed resources
	helm get manifest $(DEPLOYMENT_NAME) -n $(NS)

mongodb-show-deployed-all-info: ## show deployed Helm all information
	helm get all $(DEPLOYMENT_NAME) -n $(NS)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help mongodb-install
