# Exchange Rate

Shows foreign currency exchange rate to PLN (default: USD/PLN) based on Polish Central Bank (NBP) fixing exchange rate.

## Usage

```bash
# install
pip3 install --user 'git+https://github.com/matihost/monorepo.git#egg=exchange-rate&subdirectory=python/apps/exchange-rate'

# shows USD/PLN exchange rate
exchange-rate

# show CHF/PLN exchange rate
exchange-rate CHF
```

## Prerequisites

* Python 3.12

* Poetry

```bash
# install poetry
curl -sSL https://install.python-poetry.org | python3 -
poetry completions bash >> ~/.bash_completion
# ensure poetry will create virtualenv in project directory
poetry config virtualenvs.in-project true
```

## Develop

```bash
# Ensure you are not under custom Virtual Env (poetry detects its and use this VEnv instead creating one within application directory .venv)

echo $VIRTUAL_ENV
python -m site
# and lack of deactivate script

# init Poetry build system, install dependencies (single time)
make init

# run application
make run-exchange-rate
make run-exchange-rate-web

# run tests
make tests

# update dependencies
make update

# lint entire source code
make lint

# install into local user ~/.venv
make install

# uninstall from local user ~/.venv
make uninstall

# prepare build
make build

# clean .venv, requires make init to start develop again
make clean

# builds docker image
make build-image
# push image with tag to quay.io repository (assume docker login quay.io has been performed)
make push-image

# run image locally
make run-container

# make run container locally with shell as entrypoint
make run-container-bash
```

### Debug in VSCode

```bash
# Ensure you are not under custom Virtual Env (poetry detects its and use this VEnv instead creating one within application directory .venv)

echo $VIRTUAL_ENV
python -m site
# and lack of deactivate script
```

* Select Run and Debug on the left pane, if you haven't have *Python: Remote Attach* option available, click Settings and add [Run and Debug configuration](https://code.visualstudio.com/docs/python/debugging):

  ```json
  {
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Python: Remote Attach",
        "type": "debugpy",
        "request": "attach",
        "connect": {
          "host": "localhost",
          "port": 5678
        },
        "justMyCode": false
      }
    ]
  }
  ```

* Select Python in VS Code to use VEnv *.venv/bin/python* Python interpreter:

  * Ctrl+Shift+P 'Python: Select interpreter'
  * Select at workspace level
  * Select project *.venv/bin/python* from your project directory

* Run app in debug mode

  ```bash
  make debug
  ```

* **Warning**: Debugpy warnings:

  * does not support Python script aliases!
  * when code is under `src` you *cannot* use form:

    ```bash
    poetry run python3 -Xfrozen_modules=off -m debugpy --wait-for-client --listen 5678 exchange_rate/cli/exchange_rate.py USD
    ```

* Select breakpoint in the code.

* Select Run and Debug on the left pane and run Python debugger.
