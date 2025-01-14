.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif

init-tofu:
	tofu init -upgrade=true

*.tfvars: init-tofu ## usage: make nginx.tfvars [MODE=apply] [DEBUG=false]
	tofu $(MODE_STR) -state=state/$(subst .tfvars,,$@).tfstate \
	-var-file=$@

test: ## check whether Nginx is working
	@[ "$(shell curl -s http://localhost:8000 | grep -c nginx)" -gt 0 ] && echo OK || echo FAILED

clean: ## clean Terraform cached plugins and data
	rm -rf .terraform* *.tfstate* state

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help init-tofu *.tfvars
