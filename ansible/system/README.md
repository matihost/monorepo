# Ubuntu Tools

Various playbooks for Ubuntu machine management.

Supported Ubuntu distributions:

* For regular Ubuntu workstation - includes Gnome applications: **25.10 (questing)**

* For console only environments like Windows Linux Subsystem (WSL) or containers - does not include Gnome applications and virtualizations (like virt or vbox): **24.04 (noble)**
Container image using these playbooks is managed under [k8s/images/devcontainers](../../k8s/images/devcontainers/)

WARNING:
Scripts uses GitHub API, many repeats of invocation may lead to throttling - leading to fail some task (mainly cli installing tools from GitHub.
To check current remaining limit and when throttling will be reset call:

```bash
make get-github-quota
```

## Prerequisites (Windows)

In case your intent to manage Linux on WSL:

* Ensure you have installed WSL on your Windows: [https://documentation.ubuntu.com/wsl/latest/howto/install-ubuntu-wsl2/](https://documentation.ubuntu.com/wsl/latest/howto/install-ubuntu-wsl2/)

From Windows `cmd` shell:

```bat
# to install latest LTS version of Ubuntu
wsl --install

# to install WSL with Ubuntu 24.04
wsl --install Ubuntu-24.04

# to list currently installed distributions
wsl --list

# to terminate and unregister/uninstall particular distribution name
wsl -t DistributionName
wsl --unregister DistributionName
```

Install VS Code on Windows and Remote Development plugin.
VS Code under WSL distibution works in remote development way, that `code` cli from Windows uses WSL as remote development.
In other words `code` cannot be part of linux installed packages.

From Windows CMD terminal:

```bat
# install VS Code (or use other method to install VS Code under Windows)
winget install -e --id Microsoft.VisualStudioCode

# install Remote Development plugin
code --install-extension ms-vscode-remote.vscode-remote-extensionpack
```

Ensure Web browser from WSL is opened in Windows OS side:

```bat
# create a symlink to preferred browser on Windows side
# the symlink MUST NOT contain spaces for path in Linux
cd c:\
mklink browser.exe "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

See [Automatic opening native Windows web browser when triggered from WSL](#automatic-opening-native-windows-web-browser-when-triggered-from-wsl) for details why.

Open WSL Ubuntu distribution:

```bash
# open code from WSL Ubuntu distibution terminal, that will open code in Windows connected to WSL
code
```

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
  sudo apt -y update
  sudo apt -y upgrade
  sudo apt install -y build-essential libssl-dev libffi-dev python3-dev python3-pip gh git

  # For up to Ubuntu 22.04 you need to install it from pip3 in user space to have most modern Ansible version:
  # pip3 install ansible --user

  # For Ubuntu 24.04++ make sure Ansible is installed from apt package manager
  sudo apt install -y python3-ansible-runner

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

# run all management playbooks for most modern Ubuntu version
make all

# run all management playbooks for WSL Ubuntu Linux distribution
make wsl

# install various software for Ubuntu desktop environment
make ubuntu-setup.yaml

# to update packages and autoremove, clean unused packages
make update.yaml

# cleanup unnecessary files, journal etc.
make clean.yaml
```

## Post Setup

### Onedrive (Optional)

```bash
# to setup OAuth with Microsoft
onedrive

# then ensure OneDrive sync is running
systemctl enable --now  --user onedrive.service
journalctl --user -u onedrive --follow
```

### WSL

#### Automatic opening native Windows web browser when triggered from WSL

Some commands opens web browser for logging purposes.
Some allows providing tokens, so that you can copy and paste link and do manual logging from Windows OS web browser.
However some - like Azure CLI - requires logging via native OS even with device-code enabled - identifying WSL as non-compliant OS even when device login/token method is used.
It is possible to trigger native WIndows OS browser opening from WSL - however it requires a [setup](https://medium.com/@pcbowers/wsl-windows-10-allow-web-links-to-open-automatically-27bdc53d6f86). Windows 11 WSL provides [alternative](https://bogdan-calapod.github.io/posts/wsl-windows-browser/) as well.

From Windows WSL CMD:

```cmd
# create a symlink to preferred browser on Windows side
# the symlink MUST NOT contain spaces for path in Linux
cd c:\
mklink browser.exe "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

Then from WSL Linux distribution:

```bash
export BROWSER='/mnt/c/browser.exe'
```

This Ansible ubuntu-setup.yaml with wsl.yaml as inventory set the BROWSER variable in `~/.bash_rc` so that it works for each bash shell.
