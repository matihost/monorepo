# Learning OKD project deployment

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
# to deploy learning project on OKD cluster
# - requires free PV (for example created by okd-vms-management/prepare-pvs playbook)
make deploy.yaml
```