apply: ## run Ngnix on host port 8000
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan && \
	terraform apply -auto-approve

test: ## checl whether Nginx is working
	@[ "$(shell curl -s http://localhost:8000 | grep -c nginx)" -gt 0 ] && echo OK || echo FAILED

destroy: ## destroy Docker instance
	terraform plan && terraform destroy -auto-approve


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
