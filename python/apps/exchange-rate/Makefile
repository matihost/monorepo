CURRENCY ?= USD
run: init ## run application ensuring all deps are in place
	@pipenv run exchange-rate $(CURRENCY)

lint: init ## linter source code
	@pipenv run pylint src/ tests/

setup.py: init ## ensure setup.py exists and deps are locked with Pipfile.lock
	@pipenv-setup sync

build: ## create distribution
	python3 setup.py build

test: init ## run tests
	@pipenv run pytest tests

install: ## install locally in editable mode
	pip3 install --user -e .

uninstall: ## install locally
	pip3 uninstall -y exchange-rate

clean: ## clean
	@echo "Cleaning up distutils stuff"
	@python3 setup.py clean
	@rm -rf build
	@rm -rf dist
	@rm -rf src/*.egg-info
	@echo "Cleaning up byte compiled python stuff"
	@find . -type f -regex ".*\.py[co]$$" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Cleaning up output from test runs"
	@rm -rf tests/test_data
	@rm -rf .pytest_cache
	@rm -rf logs/
	@rm -rf .cache/
	@rm -f tests/units/.coverage*
	@rm -rf tests/results/*/*
	@find tests/ -type f -name '*.retry' -delete


clean-all: clean ## clean also virtualenv
	@pipenv --rm

init: ## ensure virtualenv contains all dependencies and app is installed in editable mode within virtual env
	@pipenv --venv 1>/dev/null || pipenv install --dev -e .

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help setup.py clean install uninstall build lint run test init

.EXPORT_ALL_VARIABLES:

PIPENV_IGNORE_VIRTUALENVS = 1
PIPENV_VENV_IN_PROJECT = true
