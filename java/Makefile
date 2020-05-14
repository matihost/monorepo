show-plugins-updates: ## show which plugins versions are not set or outdated
	mvn -T1 -s .mvn/settings.xml versions:display-plugin-updates

show-dependencies-updates: ## show which dependencies versions can be updated, but do not touch transitive version which comes with Spring Boot
	mvn -T1 -s .mvn/settings.xml versions:display-dependency-updates
	mvn -T1 -s .mvn/settings.xml versions:display-property-updates

show-dependency-tree: ## show Maven dependency tree
	mvn -s .mvn/settings.xml dependency:tree

show-dependency-resolve: ## show Maven dependencies versions
	mvn -s .mvn/settings.xml dependency:resolve

show-effective-pom: ## show Maven effective pom
	mvn -s .mvn/settings.xml help:effective-pom

show-enforcer-info: ## show Maven enforcer plugin display info
	mvn -T1 -s .mvn/settings.xml enforcer:display-info

build: ## builds the project
	mvn -s .mvn/settings.xml clean install

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates
