deploy-minikube: ## deploys echoserver on minikube
	scripts/deploy-on-minikube.sh

deploy-gke: ## deploys echoserver on gke (requires current context on some GKE cluster and access to GKE API server, if private prexix with export HTTPS_PROXY=localhost:8888)
	scripts/deploy-on-gke.sh

deploy-anthos: ## deploys echoserver on Anthos (requires current context on Anthos config cluster)
	scripts/deploy-on-anthos.sh

undeploy: ## undeply echoserver
	helm uninstall echoserver -n learning

test-minikube: ## smoke test echoserver app deployment on minikube
	curl -ksSL https://echoserver.learning.local.testing

test-gke: ## smoke test echoserver app deployment on gke
	curl -x http://localhost:8888 -ksSL https://echoserver.learning.internal.gke.shared1.dev.gcp.testing

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
