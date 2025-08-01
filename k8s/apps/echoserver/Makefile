deploy-minikube: ## deploys echoserver on minikube via Helm
	scripts/deploy-on-minikube.sh

deploy-minikube-via-script: ## deploys echoserver on minikube via bash script (kubectl apply)
	scripts/deploy-on-minikube-via-script.sh

deploy-gke-ingress: ## deploys echoserver on gke with ingress (requires current context on some GKE cluster and access to GKE API server, if private prexix with export HTTPS_PROXY=localhost:8888)
	scripts/deploy-on-gke-ingress.sh

deploy-gke-httproute: ## deploys echoserver on gke with httproute (requires current context on some GKE cluster and access to GKE API server, if private prexix with export HTTPS_PROXY=localhost:8888)
	scripts/deploy-on-gke-httproute.sh

deploy-anthos: ## deploys echoserver on Anthos (requires current context on Anthos config cluster)
	scripts/deploy-on-anthos.sh

deploy-eks: ## deploys echoserver on EKS via Helm
	scripts/deploy-on-eks.sh

deploy-aro: ## deploys echoserver on ARO (requires current context on ARO config cluster)
	scripts/deploy-on-aro.sh

undeploy: ## undeply echoserver
	helm uninstall echoserver -n learning

test-minikube: ## smoke test echoserver app deployment on minikube
	curl -ksSL https://echoserver.learning.local.testing

test-gke: ## smoke test echoserver app deployment on gke
	curl -x http://localhost:8888 -ksSL https://echoserver.learning.internal.gke.shared1.dev.gcp.testing

test-aro: ## smoke echoserver pp deployed on aro
	curl -kv https://echo.learning.apps.devshared1.northeurope.aroapp.io

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
