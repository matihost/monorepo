.EXPORT_ALL_VARIABLES:
# VBox disks is experimental
# Enabling all experimental features
VAGRANT_EXPERIMENTAL = 1

status: # show currently run VM
	vagrant status

run: ## run VM
	vagrant up

ssh: ## ssh to VM
	vagrant ssh

restart: ## restart VM with reloading Vagrantfile content w/o enforcing once provisioners
	vagrant reload

re-provision: ## restart VM with reloading Vagrantfile content and enforce once provisioner to run
	vagrant reload --provision

stop: ## stop VM
	vagrant halt

destroy: ## destroy VM
	vagrant destroy -f -g --parallel


update-vm: ## check for updates for vagrant box image
	vagrant box update

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run stop restart
