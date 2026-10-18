# Ubuntu 26.04 LTS Vagrant VM

Provisions locally Ubuntu 26.04 LTS (resolute) via VirtualBox/Vagrant.
Creates SSH keys automatically on the host for connecting to vagrant via ssh.

Feature set matches `../centos-stream-10`: extra disks (swap, XFS, LVM; Stratis is not packaged for Ubuntu), NFS server,
Apache with HTTP/HTTPS vhosts, rootful and rootless Podman containers (Quadlet), optional GUI, Guest Additions and host SSH key setup.

Relies on bento/ubuntu-26.04 build as since Hashicorp changes licence model for vagrant Canonical stopped providing own Vagrant images.

## Prerequisites

* Vagrant, VirtualBox 7.x, `sudo apt -y install sshpass` installed

* vagrant-vbguest is no more used, at it is discontinued;
  the box already ships Guest Additions (`/opt/VBoxGuestAdditions-*`), the script only verifies them

* VirtualBox is allowed to create host networks with ip ranges 172.16.0.0/12. Ensure `/etc/vbox/networks.conf` contains:

  ```txt
  * 0.0.0.0/0 ::/0
  ```

## Usage

```bash
# run VM
make run

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

## Known limitations

* Stratis is not available on Ubuntu, so `/dev/sde` and `/dev/sdf` are left unused.
* SELinux is not used (Ubuntu has AppArmor), so no SELinux contexts/booleans are configured.
* Bidirectional copy/paste with `make run-with-gui` may not work on the GNOME/Wayland session, a known VirtualBox limitation.
