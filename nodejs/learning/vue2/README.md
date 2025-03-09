# Basic Vue2

Basic project in Vue2.js

## Prerequisites

- Nvm tool installed
- [Addons](#addons) requirements met.

## Addons

The following addons were installed:

- vue-router
- [@auth0/auth0-spa-js](https://www.npmjs.com/package/@auth0/auth0-spa-js) - Auth0 authentication.
  Requires:
  Auth0 configuration. Follow [instruction](https://www.npmjs.com/package/@auth0/auth0-spa-js#configure-auth0).
  Application requires the following env variables to configure Auth0 to start/build:

  ```bash
  export VUE_APP_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
  export VUE_APP_AUTH0_CLIENT_ID="clientid"
  ```

## Usage

```bash
# install and switch to lts NodeJS via nvm, install global nodejs dependencies and local application nodejs dependencies
make init

# run locally http://localhost:3000 in the development mode
export VUE_APP_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
export VUE_APP_AUTH0_CLIENT_ID="clientid"
make run [ENV=dev]

# produce production package in build directory
# env variables for Auth0 and ENV  has to match, NODE_ENV variable is always production
export VUE_APP_AUTH0_DOMAIN="xxx-yyy.us.auth0.com"
export VUE_APP_AUTH0_CLIENT_ID="clientid"
make build [ENV=prod]

# run serve NodeJS server and expose statically build directory content
make serve

# update NPM dependencies
make update
```
