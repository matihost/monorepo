MQ_NAME := dev1

deploy: ## deploys MQ manager
	helm upgrade --install $(MQ_NAME) . -n learning --create-namespace \
    --set webconsole.ingress.host="webconsole.$(MQ_NAME).mq.learning.minikube.testing" \
    --set webconsole.ingress.class=nginx


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
