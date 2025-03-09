# Basic Vue

Basic project in Vue.js

## Prerequisites

- Nvm tool installed
- [Addons](#addons) requirements met.

## Addons

The following addons were installed:

- vue-router
- [@auth0/auth0-vue](https://www.npmjs.com/package/@auth0/auth0-vue) - Auth0 authentication.
  Requires:
  Auth0 configuration. Follow [instruction](https://www.npmjs.com/package/@auth0/auth0-vue#getting-started).
  Application requires the following env variables to configure Auth0 to start/build:

  ```bash
  export VITE_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
  export VITE_AUTH0_CLIENT_ID="clientid"
  ```

## Usage

```bash
# install and switch to lts NodeJS via nvm, install global nodejs dependencies and local application nodejs dependencies
make init

# run locally http://localhost:3000 in the development mode
export VITE_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
export VITE_AUTH0_CLIENT_ID="clientid"
make run [ENV=dev]

# produce production package in build directory
# env variables for Auth0 and ENV  has to match, NODE_ENV variable is always production
export VITE_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
export VITE_AUTH0_CLIENT_ID="clientid"
make build [ENV=prod]

# run NodeJS server and expose statically build directory content
make serve

# update NPM dependencies
make update

# builds container image, assumes make build with desired env and other parameters are set
make build-image

# run container image
make run-container

# run shell in the container image
make debug-container
```
