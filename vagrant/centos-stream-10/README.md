# CentOS 10 Stream Vagrant VM

Provisions locally CentOS 10 Stream via VirtualBox/Vagrant.
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

# download the newest base box version, if a newer one is available
make ensure-latest-base-vm

# show usage and tasks (default)
make help
```

## Known limitations

* Bidirectional copy/paste (clipboard sharing) between the host and the VM does not work with `make run-with-gui`,
  even though it is enabled in VirtualBox (`--clipboard-mode bidirectional`) and Guest Additions are installed.
  CentOS Stream 10 runs a GNOME on Wayland session, and VirtualBox Guest Additions (`VBoxClient --clipboard`)
  have no Wayland clipboard backend, which is a known VirtualBox limitation.
  CentOS Stream 10 does not ship an X11 session (Xorg), so there is no session to fall back to.
  Use `scp`/`ssh` or shared folders to move text and files instead.
