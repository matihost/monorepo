SHELL := /usr/bin/env bash
.EXPORT_ALL_VARIABLES:
# VBox disks is experimental
# Enabling all experimental features
VAGRANT_EXPERIMENTAL = 1

status: # show currently run VM
	vagrant status

run: ## run VM
	vagrant up

run-with-gui: ## run VM with GUI
	GUI=true vagrant up

ssh: ## ssh to VM
	vagrant ssh

direct-ssh: ## ssh to VM directly via ssh command
	ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.vagrant.vm vagrant@172.30.250.3

direct-run: ## run VM directly from VirtualBox
	VBoxManage startvm centos-stream-8 --type headless

direct-run-with-gui: ## run VM with GUI directly from VirtualBox
	VBoxManage startvm centos-stream-8 --type gui

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

ensure-latest-base-vm: ## cleans base box so that if Vagrant file contains newer base box it will be downloaded
	-vagrant box remove -f centos/centos-stream-8
	vagrant box add centos/centos-stream-8 https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-latest.x86_64.vagrant-virtualbox.box

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help run stop restart
