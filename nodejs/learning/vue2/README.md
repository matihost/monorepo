# Basic Vue2

Basic project in Vue2.js

Vue 2 reached end of life on 31 December 2023 and Vue CLI is in maintenance mode, so this project is kept as a learning
sample and its dependencies cannot be fully updated:

- `vue` (2.7), `vue-router` (3.x), `eslint` (8) and `eslint-plugin-vue` (8) stay on the last versions supporting Vue 2.
- `npm audit` reports vulnerabilities in Vue CLI 5 build tooling (webpack-dev-server, postcss 7 bundled in
  `@vue/component-compiler-utils` and others). They have no fix available within Vue CLI 5
  (`npm audit fix --force` would downgrade Vue CLI to version 3), and they affect build/dev time only, not the produced bundle.
- `webpack` is pinned to 5.110.1 via `overrides` in `package.json`: webpack 5.110.2+ reports
  `export 'default' ... was not found` warnings for `<style>` blocks of single file components. Remove the override
  once newer webpack builds the project without those warnings.

For a current Vue project see [vue](../vue).

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
