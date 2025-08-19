DEBUG := false
VERBOSITY := -v
ifeq ($(strip $(DEBUG)),true)
	VERBOSITY := -vvv
endif

*.yaml: ## run particular Ansible playbook file
	ansible-playbook $@ $(VERBOSITY)

all: ## run all playbooks for most modern Ubuntu version
	ansible-playbook ubuntu-setup.yaml $(VERBOSITY) && \
		ansible-playbook update.yaml $(VERBOSITY) && \
		ansclean.yaml $(VERBOSITY)

wsl: ## run all playbooks for WSL
	ansible-playbook -i wsl.yml ubuntu-setup.yaml $(VERBOSITY) && \
		ansible-playbook -i wsl.yml update.yaml $(VERBOSITY) && \
		ansible-playbook -i wsl.yml clean.yaml $(VERBOSITY)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help *.yaml
