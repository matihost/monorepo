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

### Debug in VSCode

To debug under VS Code:

* Configure Python in VS Code to use VEnv ~~/.venv/user/bin/python Python interpreter:

  * Ctrl+Shift+P 'Python: Select interpreter'
  * Select at workspace level
  * Select "~/.venv/user/bin/python"

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
  cd ~/.venv/user/bin
  ./python3 -Xfrozen_modules=off -m debugpy --wait-for-client --listen 5678 exchange-rate USD
  ```

* Select Run and Debug on the left pane and run Python debugger.
