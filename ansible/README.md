# Ansible

Various Ansible playbooks:

- [okd-installation/Makefile](okd-installation/Makefile) - to install, upgrade OKD on VirtualBox VMs
- okd-vms-management - `(start|update|shutdown)-okd-vms` - to start, shutdown or update RPMs in the  OKD cluster made of VirtualBox VMs, they stop OKD cluster before updating systems

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