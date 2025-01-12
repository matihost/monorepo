# Keycloak

Installs Keycloak as CloudRun applications connected to PostgreSQL CloudSQL database.
Exposed via GLB.

## Prerequisites

* [Compute Engine API enabled](https://console.cloud.google.com/apis/library/compute.googleapis.com) - needed to configure gcloud command fully, deployment does not use VM at all

* terragrunt, open tofu, make, zip, gcloud - present on your machine

* (Optionally, but recommended) Enable remaining required GCP APIs. Deployments ensure that particular API is enabled first, but Google often claims that API is enabled, but later on deployment claims it is not yet, and several minutes waiting is really required that API is truly enabled on GCP side.

  The list of required APIs: [Cloud Run](https://console.cloud.google.com/apis/library/run.googleapis.com), [Secret Manager](https://console.cloud.google.com/apis/library/secretmanager.googleapis.com), [SQL Component](https://console.cloud.google.com/apis/library/sql-component.googleapis.com), [SQL Admin](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com), [Binary Authz](https://console.cloud.google.com/apis/library/binaryauthorization.googleapis.com), [CloudFunctions](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com), [ArtifactRegistry](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com), [CloudBuild](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)

* Ensure you have DNS domain for [stage/dev/keycloak/terragrunt.hcl#input.url](stage/dev/keycloak/terragrunt.hcl). Change input.url parameter to meet DNS domain you wish site will be accessible from internet. I use free DNS subdomains from [https://freedns.afraid.org/](https://freedns.afraid.org/)

* (Optionally) TLS certification for your site. If you don't have one, by default Keycloak uses selfsigned TLS certificate. You may also get one via get Let's Encrypt TLS certification via HTTP ACME verfication method, follow instruction [HTTPS with Let's Encrpyt TLS certificate](#https-with-lets-encrypt-tls-certificate)

* Ensure Google Cloud Docker registry is configured. Run [../gcp-repository/](../gcp-repository/) deployment.

* Authenticate to GCP:

  ```bash
  # create separate gcloud config configuration to not mess with your current config
  gcloud config configuration create dev-keycloak
  # init your gcloud command, select us-central1-a as zone for example
  make google-authentication
  ```

* Build Docker image of Keycloak with additional plugins

  ```bash
  # run once to configure docker cli to be able to push docker image to Google Cloud Docker registry
  make configure-docker-registry
  # to build image and push to quay and GC docker repository
  make image
  ```

* Deploy Keycloak

  ```bash
  # show Keycloak Terraform deployment plan (development option)
  # agree on bucket creation for Terraform state
  make run-keycloak ENV=dev MODE=plan

  # when plan looks good, perform deployment
  make run-keycloak ENV=dev MODE=apply

  # configure A record
  # for stage/dev/keycloak/terragrunt.hcl#input.url DNS domain
  # with IP returned from the deployment output of: keycloak_glb_public_ip
  # in your DNS domain provider

  # when you change dns
  # ensure global DNS resolves obtained new DNS A record value
  nslookup id.keycloack.my.dns 1.1.1.1

  # when DNS is resolved correctly, ensure local DNS caches are cleared
  sudo resolvectl flush-caches
  ```

## Post installation steps

* Default page redirects to realm `id` user console. As fresh Keycloak has only `master` realm - fresh install will redirect to a page with 404. You need to have realm with `id`. Read on.

* Login to Keycloak admin console. Use: `/admin` prefix. TODO make super admin user and password env specific and taken from secret store.

* Follow [basic setup](https://www.keycloak.org/docs/latest/server_admin/#configuring-realms) of Keycloak - like SMTP configuration and create realm with name `id`.

## HTTPS with Let's Encrypt TLS Certificate

Keycloak deploymend takes TLS certificate from `~/.tls/id.domain` directory, or from `TLS_CRT`, `TLS_KEY` environment variables.
If none of these locations contains valid TLS files, the installation scripts creates self-signed certificate and use that for HTTPS exposure.

You can obtains Let's Encrypt with TXT ACME verification method.

If you DNS provider does not provide TXT entries or your prefer ACME HTTP verification method - then you need to :

* Install Keycloak without providing valid certificate. It will use selfsigned certificate.

Keycloak installation allows ACME HTTP verification path for Let's Encrypt verification, because it exposes `.well-known/acme-challenge/`  path as static GS bucket content.


* Get name of GS where ACME verification file needs to be placed

  ```bash
  make get-keycloak-gs-bucket ENV=prod
  ```

* Generate TLS certificate via Let's Encrypt: (certbot tool required):

  ```bash
  # to use ACME HTTP method
  make generate-letsencrypt-cert DOMAIN=id.mydomain.com

  # to use ACME TXT method (when you can edit TXT record for your domain)
  make generate-letsencrypt-cert DOMAIN=id.mydomain.com TLS_MODE=TXT
  ```

* Follow instruction on the screen.
In case of HTTP mode of ACME authentication :

  * You need to create a file and *place it in above GS root directory*. This is the proof that you control the site.

  * In case you've chosen TXT mode - you need to create TXT record in your DNS provider and ensure it is broadcasted globally.
  For example via: `nslookup -type=TXT _acme-challenge.id.mydomain.com`.

The make script also copies the generated certficate to `~/.tls` directory so that next Terraform invocation can access it. Let's Encrypt will generate TLS certificate for free for 3 months.

_Warning_: If you intent to run deployment of this module from GitHub Actions `CD` workflow, not from your local environment - you need to place/change these files as GitHub Actions Environment secrets `TLS_CRT`, `TLS_KEY` respectively.

### Refresh TLS certificate

Let's Encrypt TLS certificate is valid for 3 months.
Run these steps before certificate is invalid:

```bash
# regenerate TLS certificate
make generate-letsencrypt-cert DOMAIN=id.mydomain.com TLS_MODE=TXT

# check proposed changes
make run-keycloak MODE=plan ENV=prod


# when TLS certificate is to be changed only
make run-keycloak MODE=apply ENV=prod

# or
#
# if you run deployment from GitHub Actions CD workflow
# change GitHub Actions Environment secrets `TLS_CRT`, `TLS_KEY` and re-run CD workflow for that environment
```
