DEBUG := false
VERBOSITY := -v
ifeq ($(strip $(DEBUG)),true)
	VERBOSITY := -v=10
endif

*.yaml: ## apply particular yaml file to current context
ifndef NS
	$(error Environment NS being K8S namespace is not defined. Usage: make name.yaml NS=k8s_namespace)
endif
	kubectl apply -f $@ -n ${NS} $(VERBOSITY)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help *.yaml
