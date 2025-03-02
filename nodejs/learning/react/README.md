# Basic React

This project was bootstrapped with [Create React App (deprecated)](https://create-react-app.dev/docs/getting-started):
`npx create-react-app blog --template typescript`

## Prerequisites

- Nvm tool installed
- [Addons](#addons) requirements met.

## Addons

The following addons were installed:

- react-router
- [oidc-client-ts, react-oidc-context](https://github.com/authts/react-oidc-context/) - OIDC authentication.
  Requires:
  Application requires the following env variables to configure OIDC to start:

  ```bash
  export REACT_APP_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
  export REACT_APP_OIDC_CLIENT_ID="clientid"
  ```

  Tested with Keycloak, Auth0 and Okta OIDC providers.
  Supports all OIDC providers which exposes endpoing `REACT_APP_OIDC_ISSUER/.well-known/openid-configuration` with OIDC configuration.
  OIDC provider client has to support: Standard Flow w/o Client Authentication with `Valid redirect URLs`: `http://localhost:3000/*` and `Web origins`: `http://localhost:3000` (for local development).

## Usage

```bash
# install and switch to lts NodeJS via nvm, install global nodejs dependencies and local application nodejs dependencies
make init

# run locally http://localhost:3000 in the development mode
export REACT_APP_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
export REACT_APP_OIDC_CLIENT_ID="clientid"
make run [ENV=dev]

# produce production package in build directory
# env variables for OIDC and ENV  has to match, NODE_ENV variable is always production
export REACT_APP_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
export REACT_APP_OIDC_CLIENT_ID="clientid"
make build [ENV=prod]

# run serve NodeJS server and expose statically build directory content
make serve

# update NPM dependencies
make update
```
