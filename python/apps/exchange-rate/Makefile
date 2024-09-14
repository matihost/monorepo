TAG := latest

init: ## install poetry dependencies
	poetry install

run-exchange-rate: ## run exchange-rate from poery
	poetry run exchange-rate

run-exchange-rate-web:
	poetry run exchange-rate

build: ## build
	poetry run build

test: ## unit tests
	poetry run pytest

update: ## update dependencies
	poetry update

install: ensure-custom-user-venv ## install locally
	$(HOME)/.venv/user/bin/pip3 install --force-reinstall .

uninstall: ensure-custom-user-venv ## uninstall locally
	$(HOME)/.venv/user/bin/pip3 uninstall -y exchange-rate

clean: ## clean
	rm -rf .venv dist .pytest_cache


build-image: ## builds docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t quay.io/matihost/exchange-rate:$(TAG) .

build-image-with-venv: ## builds docker image with venv
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -f Dockerfile.venv -t quay.io/matihost/exchange-rate:$(TAG) .

push-image: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push quay.io/matihost/exchange-rate:$(TAG)

tag: ## tag latest image with additional tag
ifeq ($(TAG),latest)
	$(error TAG cannot be latest)
endif
	docker tag quay.io/matihost/ansible:latest quay.io/matihost/exchange-rate:$(TAG)

run-container: ## run image
	docker run -it --rm -p 8080:8080 quay.io/matihost/exchange-rate:${TAG}

run-container-bash: ## run image with bash
	docker run -it --rm --entrypoint sh quay.io/matihost/exchange-rate:${TAG}

ensure-custom-user-venv:
ifeq ($(wildcard $(HOME)/.venv/user),)
	python3 -m venv $(HOME)/.venv/user
	[ "$$(grep -c '.venv/user/bin' ~/.bashrc)" -gt 0 ] || echo 'PATH=$${PATH}:$${HOME}/.venv/user/bin' >> $(HOME)/.bashrc
endif

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build clean install uninstall
