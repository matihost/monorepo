TAG := latest

dist: ## create distribution
	python3 setup.py build

build: ## build
	tox

install: ## install locally in editable mode
	pip3 install --user --force-reinstall -e .

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
	@rm -rf .cache/ .venv .tox
	@rm -f tests/units/.coverage*
	@rm -rf tests/results/*/*
	@find tests/ -type f -name '*.retry' -delete


build-image: ## builds docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t quay.io/matihost/exchange-rate:$(TAG) .

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

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build clean install uninstall
