deploy-http2https-envoy: ## deploys envoy exposing envoy on HTTP and routing to HTTPS server
	ansible-playbook -i inventory/http2https deploy-envoy.yaml -v

deploy-https2many-envoy: ## eploys envoy exposing envoy on HTTPS and routing to to HTTP or HTTPS server
	ansible-playbook -i inventory/https2many deploy-envoy.yaml -v

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-http2https-envoy
