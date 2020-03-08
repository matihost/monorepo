run: ## run application ensuring all deps are in place
	@pipenv run ./src/exchange_rate/exchange_rate.py

lint: ## linter source code
	@pipenv run pylint src/

setup.py: ## ensure setup.py exists and deps are locked with Pipfile.lock
	@pipenv-setup sync

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help setup.py