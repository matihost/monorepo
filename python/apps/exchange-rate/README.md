# Exchange Rate

Shows foreign currency exchange rate to PLN (default: USD/PLN) based on Polish Central Bank (NBP) fixing exchange rate.

## Usage

```bash
# install
pip3 install --user 'git+https://github.com/matihost/learning.git#egg=exchange-rate&subdirectory=python/apps/exchange-rate'

# shows USD/PLN exchange rate
exchange-rate

# show CHF/PLN exchange rate
exchange-rate CHF
```

## Develop

```bash
# run tox build
make build

# install app locally
make install

# remove
make uninstall

# clean build leftovers
make clean

# builds docker image
make build-image
# push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
make push-image

# run image locally
make run-container

# make run container locally with shell as entrypoint
make run-container-bash
```
