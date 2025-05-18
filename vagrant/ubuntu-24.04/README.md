# Ubuntu 22.04 Vagrant VM

Provisions locally Ubuntu 22.04 via VirtualBox/Vagrant.
Creates SSH keys automatically on the host for connecting to vagrant via ssh.

Relies on bento/ubuntu-24.04 build as since Hashicorp changes licence model for vagrant Canonical stopped providing own Vagrant images.

## Prerequisites

* Vagrant, VirtualBox 7.x, `sudo apt -y install sshpass` installed

* vagrant-vbguest is no more used, at it is discontinued, vbquest additions are installed as part of the script

* VirtualBox is allowed to create host networks with ip ranges 172.16.0.0/12. Ensure `/etc/vbox/networks.conf` contains:

  ```txt
  * 0.0.0.0/0 ::/0
  ```


## Usage

```bash
# run VM
man run

# run VM with GUI and Guest Additions
make run-with-gui

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

# show usage and tasks (default)
make help
```
