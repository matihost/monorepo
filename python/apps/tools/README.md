# Tools

Contains CLI Python made tools:
* `automount-cifs` - to mount home's router NAS disk automatically (or any SAMBA/CIFS 1 endpoint)
* `setup-opendns` - to publish periodically home's network public IP to OpenDNS

## Usage

```bash
# install as root, do not use --user installation
# so that scripts will be in /usr/local/bin accessible by root
# scripts does not require to run with sudo, but they switch internally to root so that global installation is desired

sudo pip3 install 'git+https://github.com/matihost/learning.git#egg=tools&subdirectory=python/apps/tools'

# enable OpenDNS public IP sync for OpenDNS Home1 labeled network for particular user
setup-opendns -u opendns@user.com -p password Home1
```

## Develop

```bash
# install this module in local workstation
make install


# install locally in editable mode
# apps switching to root internally may stop working
make install-user

# run smoke
make run-automount-cifs
make run-setup-opendns

# ensure setup.py is synced with Pipfile.lock
make setup.py

# lint source code
make lint
```
