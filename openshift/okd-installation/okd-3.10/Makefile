dependencies: ## download Ansible roles
	rm -rf galaxy
	ansible-galaxy install -r requirements.yaml -p galaxy -f

install-all-in-one: requires-rhel-root ## install all-in-one localhost OKD
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.allinone.inventory playbooks/prerequisites.yml && \
	ansible-playbook -i ../../matihost.allinone.inventory playbooks/deploy_cluster.yml

install-matihost-okd: ## install OKD with my configuration
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.inventory playbooks/prerequisites.yml && \
	ansible-playbook -i ../../matihost.inventory playbooks/deploy_cluster.yml

upgrade-from-3.9: ## upgrade from previous 3.9 installation
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.upgrade.inventory playbooks/openshift-master/openshift_node_group.yml && \
	ansible-playbook -i ../../matihost.upgrade.inventory playbooks/byo/openshift-cluster/upgrades/v3_10/upgrade.yml

install-metrics-subsystem: requires-rhel-root ## install metrics subsystem (Heapster & Hawkular on C*)
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.inventory playbooks/openshift-metrics/config.yml -e openshift_metrics_install_metrics=true

requires-rhel-root:
	test `whoami` == root -a -e /etc/redhat-release	

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help