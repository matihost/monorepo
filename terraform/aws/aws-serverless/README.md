# AWS Serverless Framework API exposure

Expose API via AWS Lambda deployed via Serverless Framework.

## Prerequisites

* Python 3.13

* Poetry

```bash
# install poetry
curl -sSL https://install.python-poetry.org | python3 -
poetry completions bash >> ~/.bash_completion
# ensure poetry will create virtualenv in project directory
poetry config virtualenvs.in-project true
```

* Nvm

```bash
CURRENT_VERSION="$(curl -sL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r ".tag_name")"
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${CURRENT_VERSION}/install.sh" | bash
~/.nvm/nvm.sh && \
  nvm install --lts && \
  npm i serverless -g
```

* Logged to AWS Account.

## Develop

```bash
# init Poetry build system, init Serverless Framework tooling (single time)
make init

# run Fast API app locally (pure Python)
make run-locally

# run app with autoreloading upon code changes (pure Python)
make dev-locally

# run Serverless Framework in offline aka local mode
make run-sls-offline

# deploy api to AWS, usage: make deploy ENV=dev [DEBUG=false]
make deploy

# undeploy / remove api from AWS, usage: make undeploy ENV=dev [DEBUG=false]
make undeploy

# show Serverless list of deployed version of your Serverless Service and all the deployed functions and their versions
make show-state
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

* Select Python in VS Code to use VEnv .venv/bin/python Python interpreter:

  * Ctrl+Shift+P 'Python: Select interpreter'
  * Select at workspace level
  * Select project ".venv/bin/python" from your project directory

* Run app in debug mode

  ```bash
  make debug
  ```

* Select breakpoint in the code

* Select Run and Debug on the left pane and run Python debugger.
