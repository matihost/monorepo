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
# push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
make push-image

# run image locally
make run-container

# make run container locally with shell as entrypoint
make run-container-bash
```

### Debug in VSCode

To debug under VS Code:

* Configure Python in VS Code to use VEnv ~~/.venv/user/bin/python Python interpreter:

  * Ctrl+Shift+P 'Python: Select interpreter'
  * Select at workspace level
  * Select project ".venv/bin/python" or "~/.venv/user/bin/python" if you test on user space virtualenv

* Select Run and Debug on the left pane, click Settings

* Add [Run and Debug configuration](https://code.visualstudio.com/docs/python/debugging):

  ```json
  {
    "version": "0.2.0",
    "configurations": [
      {
        "name": "Python: Remote Attach",
        "type": "python",
        "request": "attach",
        "connect": {
          "host": "localhost",
          "port": 5678
        },
        "justMyCode": true
      }
    ]
  }
  ```

* Install app into venv in editable mode, so that any file modification will be automatically visible by VS Code:

  ```bash
  make develop
  ```

* Select breakpoint in the code

* Run external debugger from venv directory (important: otherwise VSCode cannot match code with breakpoints...):

  ```bash
  poetry run python3 -Xfrozen_modules=off -m debugpy --wait-for-client --listen 5678 exchange-rate USD
  ```

* Select Run and Debug on the left pane and run Python debugger.
