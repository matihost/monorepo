DEBUG := false
VERBOSITY := -v
ifeq ($(strip $(DEBUG)),true)
	VERBOSITY := -vvv
endif

*.yaml: ## run particular Ansible playbook file
	ansible-playbook $@ $(VERBOSITY)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help *.yaml
