# Tools

Contains CLI Python made tools:
* `automount-cifs` - to mount home's router NAS disk automatically (or any SAMBA/CIFS 1 endpoint)
* `setup-opendns` - to publish periodically home's network public IP to OpenDNS

## Usage

```bash
# install
pip3 install --user 'git+https://github.com/matihost/learning.git#egg=tools&subdirectory=python/apps/tools'

# enable OpenDNS public IP sync for OpenDNS Home1 labeled network for particular user
setup-opendns -u opendns@user.com -p password Home1
```


## Develop

```bash

# install this module in local workstation
make install 

# run smoke test
make run

# ensure setup.py is synced with Pipfile.lock
make setup.py

# lint source code
make lint
```
