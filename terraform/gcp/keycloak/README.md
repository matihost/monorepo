# Keycloak

Installs Keycloak as CloudRun applications connected to PostgreSQL CloudSQL database.
Exposed via GLB.

## Prerequisites


* [Compute Engine API enabled](https://console.cloud.google.com/apis/library/compute.googleapis.com) - needed to configure gcloud command fully, deployment does not use VM at all

* terragrunt, terraform, make, zip, gcloud - present on your machine, tested on Ubuntu 22.10

* (Optionally, but recommended) Enable remaining required GCP APIs. Deployments ensure that particular API is enabled first, but Google often claims that API is enabled, but later on deployment claims it is not yet, and several minutes waiting is really required that API is truly enabled on GCP side.

  The list of required APIs: [Cloud Run](https://console.cloud.google.com/apis/library/run.googleapis.com), [SQL Component](https://console.cloud.google.com/apis/library/sql-component.googleapis.com), [SQL Admin](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com), [Binary Authz](https://console.cloud.google.com/apis/library/binaryauthorization.googleapis.com), [CloudFunctions](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com), [ArtifactRegistry](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com), [CloudBuild](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)

* Ensure you have DNS domain for [stage/dev/keycloak/terragrunt.hcl#input.url](stage/dev/keycloak/terragrunt.hcl). Change input.url parameter to meet DNS domain you wish site will be accessible from internet. I use free DNS subdomains from [https://freedns.afraid.org/](https://freedns.afraid.org/)

* Authenticate to GCP:

  ```bash
  # create separate gcloud config configuration to not mess with your current config
  gcloud config configuration create dev-keycloak
  # init your gcloud command, select us-central1-a as zone for example
  make google-authentication
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
  ```

## Post installation steps

* Default page redirects to realm `id` user console. As fresh Keycloak has only `master` realm - fresh install will redirect to a page with 404. You need to have realm with `id`. Read on.

* Login to Keycloak admin console. Use: `/admin` prefix. TODO make super admin user and password env specific and taken from secret store.

* Follow [basic setup](https://www.keycloak.org/docs/latest/server_admin/#configuring-realms) of Keycloak - like SMTP configuration and create realm with name `id`.
