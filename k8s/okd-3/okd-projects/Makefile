login: ## login to OKD cluster
	oc login https://master.matihost:8443 -u admin

cluster-status: ## shows OKD cluster status
	@oc status -v --all-namespaces
	@echo "Pods with issues: `oc get po --all-namespaces --no-headers  | grep -q -v Running`"

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help login cluster-status
