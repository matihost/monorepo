clean: ## clean build results
	rm -rf target

build: ## builds the project
	mvn -s .mvn/settings.xml clean install

ALGORITHMS := $(shell ls src/main/java/org/matihost/algorithms/euler |cut -d'.' -f1)  
${ALGORITHMS}: ## run ProblemX
	java -cp target/project-euler-1.0.0-SNAPSHOT.jar org.matihost.algorithms.euler.$@


docs:
	asciidoctor -r asciidoctor-diagram,asciidoctor-mathematical -b html -D target *.ad
	asciidoctor -r asciidoctor-pdf,asciidoctor-diagram,asciidoctor-mathematical -b pdf -D target *.ad

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

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help