# CentOS 8 Vagrant VM

Provisions locally CentOS 8 via VirtualBox/Vagrant.
Creates SSH keys automatically on the host (this part assumes apt Ubuntu/Debian

```bash
# run VM
man run

# ssh to VM via vagrant
make ssh
# or directly via ssh (keys are automatically provisioned upon initial VM boot)
ssh vagrant@172.30.250.3

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
