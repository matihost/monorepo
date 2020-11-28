deploy-minikube: ## deploys echoserver on minikube
	scripts/deploy-on-minikube.sh


test-minikube: ## smoke test echoserver app deployment on minikube
	curl -ksSL https://echoserver.learning.testing

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
