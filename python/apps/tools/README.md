# Tools

Contains CLI Python made tools:

* `automount-cifs` - to mount home's router NAS disk automatically (or any SAMBA/CIFS 1 endpoint)
* `setup-opendns` - to publish periodically home's network public IP to OpenDNS

## Usage

```bash
# install as root, do not use --user installation
# so that scripts will be in /usr/local/bin accessible by root
# scripts does not require to run with sudo, but they switch internally to root so that global installation is desired

sudo pip3 install 'git+https://github.com/matihost/monorepo.git#egg=tools&subdirectory=python/apps/tools'

# enable OpenDNS public IP sync for OpenDNS Home1 labeled network for particular user
setup-opendns -u opendns@user.com -p password Home1
```

## Develop

```bash
# init Poetry build system, install dependencies (single time)
make init

# run tool
make run-automount-cifs
make run-setup-opendns

# run tests
make tests

# update dependencies
make update

# lint entire source code
make lint
# install this module as root, so that command are visible for everyone
make install

# uninstall
make uninstall

# install into local user ~/.venv
# apps switching to root internally may stop working
make install-user

# uninstall from local user ~/.venv
make uninstall-user

# prepare build
make build

# clean .venv, requires make init to start develop again
make clean
```
