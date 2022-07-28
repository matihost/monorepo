# CentOS 9 Stream Vagrant VM

Provisions locally CentOS 9 Stream via VirtualBox/Vagrant.
Creates SSH keys automatically on the host for connecting to vagrant via ssh

## Prerequisites

* Vagrant, VirtualBox, sshpass installed

* `vagrant plugin install vagrant-vbguest` installed

* VirtualBox is allowed to create host networks with ip ranges 172.16.0.0/12. Ensure `/etc/vbox/networks.conf` contains:

  ```txt
  * 0.0.0.0/0 ::/0
  ```

## Usage

```bash
# run VM
man run

# ssh to VM via vagrant
make ssh
# or directly via ssh (keys are automatically provisioned upon initial VM boot)
make direct-ssh

#  restart VM with reloading Vagrantfile content w/o enforcing once provisioners
make restart

# restart VM with reloading Vagrantfile content and enforce once provisioner to run
make re-provision

# stop VM
make stop

# remove VM from disk
make destroy

# check for updates for vagrant box image
make update-vm

# show usage and tasks (default)
make help
```
