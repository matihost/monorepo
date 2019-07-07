show-plugins-updates: ## show which plugins versions are not set or outdated
	mvn -T1 versions:display-plugin-updates

show-dependencies-updates: ## show which dependencies versions can be updated, but do not touch transitive version which comes with Spring Boot
	mvn -T1 versions:display-dependency-updates
	mvn -T1 versions:display-property-updates

show-dependency-tree: ## show Maven dependency tree
	mvn dependency:tree

show-dependency-resolve: ## show Maven dependencies versions
	mvn dependency:resolve

show-effective-pom: ## show Maven effective pom
	mvn help:effective-pom

show-enforcer-info: ## show Maven enforcer plugin display info
	mvn -T1 enforcer:display-info

build: ## builds the project
	mvn clean install

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates