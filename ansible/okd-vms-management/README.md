# VMs Management

## Prerequisites

Ansible 2.6+ installed

Ubuntu:

```bash
sudo apt install ansible
```

RHEL 7.x:

```bash
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
sudo yum --disablerepo=* --enablerepo="rhel-7-server-extras-rpms,rhel-7-server-rpms" install ansible
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
```