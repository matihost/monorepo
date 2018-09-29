# Metrics subsystem playbook requires java 
dependencies:
	test `whoami` == root -a -e /etc/redhat-release
	rm -rf galaxy
	ansible-galaxy install -r requirements.yaml -p galaxy -f


# all in one localhost
install-all-in-one: requires-rhel-root
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.allinone.inventory playbooks/prerequisites.yml && \
	ansible-playbook -i ../../matihost.allinone.inventory playbooks/deploy_cluster.yml


# my configuration of the OKD cluster
install-matihost-okd: requires-rhel-root
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.inventory playbooks/prerequisites.yml && \
	ansible-playbook -i ../../matihost.inventory playbooks/deploy_cluster.yml


# to install metrics subsystem (Heapster, Hawkular on Cassandra)
install-metrics-subsystem: requires-rhel-root
	cd galaxy/openshift-ansible && \
	ansible-playbook -i ../../matihost.inventory playbooks/openshift-metrics/config.yml -e openshift_metrics_install_metrics=true

requires-rhel-root:
	test `whoami` == root -a -e /etc/redhat-release	