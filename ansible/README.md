# Ansible

Various Ansible playbooks:

- `*-okd-vms` - to start, shutdown and update RPMs in the  OKD cluster made of VirtualBox VMs

## Prerequisites

Ansible 2.6+ installed

Ubuntu:

```bash
sudo apt install ansible
```

RHEL 7.x:

```bash
sudo yum --disablerepo=* --enablerepo="rhel-7-server-extras-rpms,rhel-7-server-rpms" install ansible
```

## Sample usage

```bash
ansible-playbook start-okd.vms
```