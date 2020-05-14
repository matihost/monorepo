*.yaml: ## run particular Ansible playbook file
	ansible-playbook $@ -v

test-inventory: ## validate inventories in init and yaml formats
	ansible wieloslaw3* -i inventory/sample_yaml --list-hosts
	ansible ste* -i inventory/sample_ini --list-hosts
	ansible atlanta -i inventory/sample_ini --list-hosts
	ansible rale* -i inventory/sample_yaml --list-hosts
	ansible all -i inventory/all_in_one.yaml --list-hosts

debug-variable: ## print calculated fact
	ansible localhost -i inventory/sample_yaml -m debug -a "msg='{{ vars.hostvars['wieloslaw9.some.fm'].additional_var }}'"
	ansible localhost -i inventory/sample_ini -m debug -a "msg='{{ vars.hostvars.host1.escape_pods }}'"

show-system: ## show localhost Ansible variables
	ansible localhost -m setup

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help *.yaml
