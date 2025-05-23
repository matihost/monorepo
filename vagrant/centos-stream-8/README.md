# CentOS 8 Stream Vagrant VM

Provisions locally CentOS 8 Stream via VirtualBox/Vagrant.
Creates SSH keys automatically on the host for connecting to vagrant via ssh

## Prerequisites

* Vagrant, VirtualBox 7.x, `sudo apt -y install sshpass` installed

* vagrant-vbguest is no more used, at it is discontinued, vbquest additions are installed as part of the script

* VirtualBox is allowed to create host networks with ip ranges 172.16.0.0/12. Ensure `/etc/vbox/networks.conf` contains:

  ```txt
  * 0.0.0.0/0 ::/0
  ```

* Download base OS image:

  ```bash
  # download Vagrant image
  make ensure-latest-base-vm
  ```

## Usage

```bash
# download Vagrant image
make ensure-latest-base-vm

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

# cleans base box so that if Vagrant file contains newer base box it will be downloaded
make ensure-latest-base-vm

# show usage and tasks (default)
make help
```
