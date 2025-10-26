SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:

init: ## install poetry dependencies, required to be run once
	poetry config virtualenvs.in-project true
	poetry install

run-automount-cifs: ## run application ensuring all deps are in place
	poetry run automount-cifs

run-setup-open-dns: ## run application ensuring all deps are in place
	poetry run setup-opendns

debug-automount-cifs: ## debug automouunt-cifs from poetry
	PYTHONPATH=src poetry run python3 -m debugpy --wait-for-client --listen 5678 -m tools.cli.automount_cifs

debug-setup-open-dns: ## debug setup_opendns from poetry
	PYTHONPATH=src poetry run python3 -m debugpy --wait-for-client --listen 5678 -m tools.cli.setup_opendns

build: ## build
	poetry build

tests: ## unit tests
	poetry run pytest

update: ## update dependencies
	poetry update && echo "Run 'poetry show' to show current versions in poetry.lock and update dependency ranges in pyproject.toml"

lint: # run ruff on all files
	poetry run ruff check  --fix --force-exclude
	poetry run ruff format --force-exclude

install: ## install globally to make cli switchable to root working
	sudo pip3 install . --break-system-packages

install-user: ensure-custom-user-venv ## install locally  (apps switching to root internally may stop working)
	$(HOME)/.venv/user/bin/pip3 install --force-reinstall .

uninstall: ## uninstall locally
	sudo pip3 uninstall -y tools --break-system-packages

uninstall-user: ensure-custom-user-venv ## uninstall locally
	$(HOME)/.venv/user/bin/pip3 uninstall -y tools

clean: ## clean
	rm -rf .venv dist .pytest_cache .ruff_cache
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


ensure-custom-user-venv:
ifeq ($(wildcard $(HOME)/.venv/user),)
	python3 -m venv $(HOME)/.venv/user
	[ "$$(grep -c '.venv/user/bin' ~/.bashrc)" -gt 0 ] || echo 'PATH=$${PATH}:$${HOME}/.venv/user/bin' >> $(HOME)/.bashrc
endif

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help clean install uninstall build tests init
