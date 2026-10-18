# Basic React

Basic React (TypeScript) application with OIDC authentication, built with [Vite](https://vite.dev/) and tested with
[Vitest](https://vitest.dev/).

## Prerequisites

- Nvm tool installed
- [Addons](#addons) requirements met.

## Addons

The following addons were installed:

- react-router
- [oidc-client-ts, react-oidc-context](https://github.com/authts/react-oidc-context/) - OIDC authentication.
  Requires:
  Application requires the following env variables (available in the code as `import.meta.env.VITE_*`)
  to configure OIDC to start:

  ```bash
  export VITE_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
  export VITE_OIDC_CLIENT_ID="clientid"
  ```

  Tested with Keycloak, Auth0 and Okta OIDC providers.
  Supports all OIDC providers which exposes endpoing `VITE_OIDC_ISSUER/.well-known/openid-configuration` with OIDC configuration.
  OIDC provider client has to support: Standard Flow w/o Client Authentication with `Valid redirect URLs`: `http://localhost:3000/*` and `Web origins`: `http://localhost:3000` (for local development).

## Usage

```bash
# install and switch to lts NodeJS via nvm, install global nodejs dependencies and local application nodejs dependencies
make init

# run locally http://localhost:3000 in the development mode
export VITE_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
export VITE_OIDC_CLIENT_ID="clientid"
make run [ENV=dev]

# produce production package in dist directory
# env variables for OIDC and ENV  has to match, NODE_ENV variable is always production
export VITE_OIDC_ISSUER="https://mydomain.my/realms/keycloakrealm"
export VITE_OIDC_CLIENT_ID="clientid"
make build [ENV=prod]

# serve statically dist directory content (vite preview) on http://localhost:3000
make serve

# run unit tests (Vitest)
npm test

# type check
npm run typecheck

# update NPM dependencies
make update
```
