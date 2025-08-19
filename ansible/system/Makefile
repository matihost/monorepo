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

get-github-quota: ## run current GitHub API quota
	@echo "Remaining: $(shell curl -sL   -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/rate_limit | jq -r '.resources.core.remaining')"
	@echo "Quota reset time: $(shell curl -sL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/rate_limit | jq -r '.resources.core.reset' | xargs -I % date -d @%)"

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help *.yaml
