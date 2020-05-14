# OKD 3.11 installation

Instruction how to setup OKD cluster on single Linux based host with VirtualBox with 3 VMs.

OKD cluster characteristic:

* one master
* one infra node (DNS *.apps.matihost must point to that node)
* one app node,
* infra node is also compute node (normally it is not)
* NFS on master configured with PVs for ImageRegistry

Inventory file reference: `galaxy/openshift-ansible/inventory/hosts.example`

## Prerequisites

* Single Linux machine, tested on Ubuntu with 16GiB  RAM
* VirtualBox with 3 x CentOS/RHEL 7.x VMs in the same HostNetwork
  * 2 GiB RAM for each VM is enough
  * HostNetwork has disabled DHCP and Network adapter is manually defined
* DNS bind server on host machine pointing **.apps.matihost*  to one of VMs (which will be infra node). Normally there should be LB exposing infra nodes and *.apps.matihost DNS point to that.
  * Each VM has setup own network adapter manually (`mmcli`)
  * VMs should use DNS server on host to resolve themselves
  * **VMs hostname (`uname -n` or `hostname -f`) [MUST match](https://github.com/openshift/openshift-ansible/issues/9730#issuecomment-415482818) the name used in inventory file**
* Ansible 2.6.5 + (and < 2.7) installed on CentOS/RHEL master node

```bash
# install EPEL
sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# on RHEL 7
sudo subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"
sudo yum install ansible
```

* SSH keys propagated from master to other VMs allowing Ansible to SSH to every VM as root

## Installation

```bash
ssh root@master
mkdir -p ~/src && cd ~/src
git clone https://github.com/matihost/learning
cd learning/openshift/okd-installation/okd-3.11

make dependencies
make install-matihost-okd

# to install all-in-one
#make install-all-in-one
```
