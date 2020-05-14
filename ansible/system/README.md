# Ubuntu Tools

Various playbooks for Ubuntu machine management.

Supported Ubuntu distribution: **20.04 LTS (focal)**

## Running

```bash
# make sure Ansible is installed from pip3
pip3 install ansible --user
```

then:

```bash
# to update packages and autoremove, clean unused packages
make update.yaml

# cleanup unnecessary files, journal etc.
make clean.yaml

# install various software for Ubuntu desktop environment
make ubuntu-setup.yaml
```
