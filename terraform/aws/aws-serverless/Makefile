ENV := dev

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	SLS_DEBUG_OPTS := --debug
endif


init: ## init Poetry build system, init Serverless Framework tooling (single time)
	. ${HOME}/.nvm/nvm.sh && nvm use && \
		poetry config virtualenvs.in-project true && poetry install && \
	  npm install

run-locally: ## run Fast API app locally (pure Python)
	poetry run python src/website/api/api.py

dev-locally: ## run app with autoreloading upon code changes (pure Python)
	poetry run fastapi dev src/website/api/api.py

debug: ## debug app (pure Python)
	PYTHONPATH=src poetry run python3 -m debugpy --wait-for-client --listen 5678 -m website.api.api

run-sls-offline: ## run Serverless Framework in offline aka local mode
	poetry run node_modules/serverless/run.js offline --stage offline

deploy: ## deploy api to AWS, usage: make deploy ENV=dev [DEBUG=false]
	node_modules/serverless/run.js deploy --stage $(ENV) $(SLS_DEBUG_OPTS)

undeploy: ## undeploy / remove api from AWS, usage: make undeploy ENV=dev [DEBUG=false]
	node_modules/serverless/run.js remove --stage $(ENV) $(SLS_DEBUG_OPTS)


show-state: ## show Serverless list of deployed version of your Serverless Service and all the deployed functions and their versions
	node_modules/serverless/run.js deploy list --stage $(ENV) $(SLS_DEBUG_OPTS)
	node_modules/serverless/run.js deploy list functions --stage $(ENV) $(SLS_DEBUG_OPTS)

build: ## build
	poetry build

tests: ## unit tests
	poetry run pytest

update: ## update dependencies
	ncu -u
	npm update
	poetry update && echo "Run 'poetry show' to show current versions in poetry.lock and update dependency ranges in pyproject.toml"


lint: # run ruff on all files
	poetry run ruff check  --fix --force-exclude
	poetry run ruff format --force-exclude

clean: ## clean
	rm -rf .venv dist .pytest_cache .ruff_cache .serverless node_modules
	@echo "Cleaning up byte compiled python stuff"
	@find . -type f -regex ".*\.py[co]$$" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Cleaning up output from test runs"
	@rm -rf tests/test_data
	@rm -rf .pytest_cache
	@rm -rf logs/
	@rm -rf .cache/
	@rm -ff tests/units/.coverage*
	@rm -rf tests/results/*/*
	@-find tests/ -type f -name '*.retry' -delete 2>/dev/null


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build clean tests
