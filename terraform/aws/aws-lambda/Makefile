VERSION := 1.0.0
apply: ## setup cron triggered Lambda function
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve

test: ## invoke Lambda programatically
	//TODO

show-state: ## show terraform.state
	terraform state list
	terraform show

destroy: ## destroy lamda resources
	terraform plan && terraform destroy -auto-approve && \
	$(MAKE) destroy-prerequisites

build: ## prepare compressed Lambda function ready to be upload to s3
	mkdir -p build
	zip build/sli-synthetic-client.zip sli-synthetic-client.py


prepare: build ## prepare S3 bucket required by Lambda
	@cd prerequisites && \
	terraform init -upgrade=true && \
	terraform validate && \
	terraform plan -lock=false && \
	terraform apply -auto-approve && \
	aws s3 cp ../build/sli-synthetic-client.zip s3://`terraform output lambda_bucket`/lambda/sli-synthetic-client/$(VERSION)/sli-synthetic-client.zip


destroy-prerequisites:
	@rm -rf build
	@cd prerequisites && \
	terraform plan && terraform destroy -auto-approve



help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
