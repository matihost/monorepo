# OKD 3.9 installation

Instruction how to setup OKD cluster on single Linux based host with VirtualBox with 3 VMs.

OKD cluster characteristic:

* one master
* one infra node (DNS *.apps.matihost must point to that node)
* one app node,
* all nodes are schedulable including infra nodes (normally it is not)
* NFS on master configured with PVs for ImageRegistry

Inventory file reference: `galaxy/openshift-ansible/inventory/hosts.example`

## Prerequisites

* Single Linux machine, tested on Ubuntu with 16GiB  RAM
* VirtualBox with 3 x RHEL 7.x VMs in the same HostNetwork
  * (minimum) 2 GiB RAM for each VM  (w/o metrics subsystem)
  * (optimal) 4 GiB RAM foe each VM when metrics subsystem is planned to be installed. Metric subsystem itself takes all the time 1-2 core and ~3 GiB memory.
  * HostNetwork has disabled DHCP and Network adapter is manually defined
* DNS bind server on host machine pointing **.apps.matihost*  to one of VMs (which will be infra node). Normally there should be LB exposing infra nodes and *.apps.matihost DNS point to that.
  * Each VM has setup own network adapter manually (`mmcli`)
  * VMs should use DNS server on host to resolve themselves
* Ansible installed on RHEL master node

```bash
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
sudo yum install ansible
```

OCP 3.9 requires a bit newer Ansible than is present in RHEL 7.x package

```bash
ansible --version

# if less than 2.4.4 install
sudo rpm -Uvh https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.4.4.0-1.el7.ans.noarch.rpm
```

* SSH keys propagated from master to other VMs allowing Ansible to SSH to every VM as root

## Installation

```bash
ssh root@master
mkdir -p ~/src && cd ~/src
git clone https://github.com/matihost/learning
cd learning/openshift/okd-installation/okd-3.9

make dependencies
make install-matihost-okd

# (optional) to install metric subsystem (Heapster, Hawkular on Cassandra) afterwards
make install-metrics-subsystem
```