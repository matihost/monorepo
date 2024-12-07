clean: ## clean build data
	rm -rf target

docs: ## generate html/pdf from *.ad in target directory
	@mkdir -p target
	asciidoctor -r asciidoctor-diagram -b html -D target *.ad
	asciidoctor -r asciidoctor-pdf,asciidoctor-diagram -b pdf -D target *.ad

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help clean docs
