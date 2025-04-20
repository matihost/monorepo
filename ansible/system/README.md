# Ubuntu Tools

Various playbooks for Ubuntu machine management.

Supported Ubuntu distribution: **25.04 (plucky)**

## Prerequisites

* Ensure your Linux user is on sudoers with NOPASSWD. In Ubuntu it can be achieved by

  ```bash
  sudo groupadd admin
  sudo usermod -aG admin <your user name>
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
  # install Python3, GitHub CLI and Git
  sudo apt install -y build-essential libssl-dev libffi-dev python3-dev python3-pip gh git

  # make sure Ansible is installed
  sudo apt install -y python3-ansible-runner

  # you cannot install it from pip3 anymore in user space
  # pip3 install ansible --user

  # ensure user Python apps can be run
  echo 'PATH="$HOME/.local/bin:$HOME/bin:$PATH"' >> ~/.bashrc
  ```

* Setup git and checkout this repo

  ```bash
  # setup your git user name and email
  git config --global user.name "Name Surname"
  git config --global user.email "your@email"

  # clone this repo
  mkidr -p ~/src && cd ~/src
  gh repo clone matihost/monorepo

  # setup pre-commit hooks in the checkout repo
  cd monorepo
  pre-commit install --install-hooks

  # go to this playbook location
  cd monorepo/ansible/system
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

## Ubuntu upgrade instructions

* Check
