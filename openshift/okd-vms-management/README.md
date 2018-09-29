# VMs Management

## Prerequisites

- Ansible 2.6+
- Pip
- openshift pip module (k8s ansible module dependency)

Ubuntu:

```bash
sudo apt-add-repository ppa:ansible/ansible
sudo apt install ansible
sudo apt install python-pip
sudo pip install openshift
```

## Running

```bash
# to start VirtualBox VMs with OKD cluster
make start-okd-vms.yaml

# to shutdown VirtualBox VMs with OKD cluster
make shutdown-okd-vms.yaml

# to update RPMs packages in the  VirtualBox VMs of  OKD cluster
# it shutdowns all origin services before that and attempt to start them after update
# VMs snapshots are recommended before that
make update-okd-vms.yaml

# to install and setup bare RHEL/CentOS boxes so that OKD can be installed
# master has to be accessible and has correct config, see playbook file for details
make prepare-okd-installation.yaml

# to prepare NFS volumes and install PVs on OKD cluster for apps usage
make prepare-pvs.yaml
```