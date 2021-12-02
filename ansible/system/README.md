# Ubuntu Tools

Various playbooks for Ubuntu machine management.

Supported Ubuntu distribution: **21.10 (impish)**

## Prerequisites

* Ensure your Linux user is on sudoers with NOPASSWD. In Ubuntu it can be achieved by

  ```bash
  groupadd admin
  usermod -aG admin <your user name>
  sudo visudo
  ```

  and ensure the following entries are set:

  ```txt
  # Members of the admin group may gain root privileges
  %admin ALL=(ALL) NOPASSWD: ALL

  # Allow members of group sudo to execute any command
  %sudo   ALL=(ALL:ALL) NOPASSWD: ALL
  ```

* Install Python and Ansible

  ```bash
  # install Python3
  sudo apt install -y build-essential libssl-dev libffi-dev python3-dev python3-pip

  # make sure Ansible is installed from pip3
  pip3 install ansible --user

  # ensure user Python apps can be run
  echo 'PATH="$HOME/.local/bin:$HOME/bin:$PATH"' >> ~/.bashrc
  ```

## Running

```bash
# install various software for Ubuntu desktop environment
make ubuntu-setup.yaml

# to update packages and autoremove, clean unused packages
make update.yaml

# cleanup unnecessary files, journal etc.
make clean.yaml
```

## Post Setup

### Onedrive

```bash
# to setup OAuth with Microsoft
onedrive

# then ensure OneDrive sync is running
systemctl enable --now  --user onedrive.service
journalctl --user -u onedrive --follow
```
