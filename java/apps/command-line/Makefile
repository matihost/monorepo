BASE := quay.io/matihost/commandline
TAG := latest


run: ## run command-line
	mvn -am clean spring-boot:run

build: ## build
	mvn -am clean package

build-docker: build ## build docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build --build-arg JAR_FILE=target/*.jar -t $(BASE):$(TAG) .

run-docker: ## run app from docker
	docker run -it --rm $(BASE):${TAG}

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push $(BASE):$(TAG)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates
