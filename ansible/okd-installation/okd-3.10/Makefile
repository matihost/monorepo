# Assumptions that playbooks are run
# from RHEL with access to GitHub to download openshift-ansible
# with access to GitHub to download openshift/ansible repository
# from root
dependencies:
	test `whoami` == root -a -e /etc/redhat-release
	ansible-galaxy install -r requirements.yaml -p galaxy -f

# all in one localhost, allow all authen mode
install-all-in-one:
	cd galaxy/openshift-ansible && \
	ansible-playbook -i inventory/hosts.localhost playbooks/prerequisites.yml && \
	ansible-playbook -i inventory/hosts.localhost playbooks/deploy_cluster.yml


# my configuration of the OKD cluster
install-matihost-okd:
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.inventory playbooks/prerequisites.yml && \
	ansible-playbook -i ../../matihost.inventory playbooks/deploy_cluster.yml

# upgrade from previous 3.9 installation
upgrade-from-3.9:
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.upgrade.inventory playbooks/openshift-master/openshift_node_group.yml && \
	ansible-playbook -i ../../matihost.upgrade.inventory playbooks/byo/openshift-cluster/upgrades/v3_10/upgrade.yml
