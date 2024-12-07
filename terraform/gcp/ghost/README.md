# Ghost Blog Deployment

Ghost blog deployment using Cloud Run, Cloud DB and GLB.

## Repository Structure

This Git repository is structured as follows:

* [module](module) - contains Terraform modules for Ghost deployment and Cloud Function for posts management.
* [stage](stage) - contains Terragrunt deployment configurations per environment (dev, prod)
* [docs](docs) - contains documentation including architecture, user guide, sre guide, etc. For PDF/HTML version of the documentation - see artifacts in Releases.
* [Makefile](Makefile) - entrypoint for SRE engineer to perform deployment

## Prerequisites

* Free Tier GCP Project
* [Compute Engine API enabled](https://console.cloud.google.com/apis/library/compute.googleapis.com) - needed to configure gcloud command fully, deployment does not use VM at all
* terragrunt, terraform, make, zip, gcloud - present on your machine, tested on Ubuntu 22.10
* (Optionally, but recommended) Enable remaining required GCP APIs. Deployments ensure that particular API is enabled first, but Google often claims that API is enabled, but later on deployment claims it is not yet, and several minutes waiting is really required that API is truly enabled on GCP side.
The list of required APIs: [Cloud Run](https://console.cloud.google.com/apis/library/run.googleapis.com), [SQL Component](https://console.cloud.google.com/apis/library/sql-component.googleapis.com), [SQL Admin](https://console.cloud.google.com/apis/library/sqladmin.googleapis.com), [Binary Authz](https://console.cloud.google.com/apis/library/binaryauthorization.googleapis.com), [CloudFunctions](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com), [ArtifactRegistry](https://console.cloud.google.com/apis/library/artifactregistry.googleapis.com), [CloudBuild](https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com)
* Ensure you have DNS domain for [stage/dev/ghost/terragrunt.hcl#input.url](stage/dev/ghost/terragrunt.hcl). Change input.url parameter to meet DNS domain you wish site will be accessible from internet. I use free DNS subdomains from [https://freedns.afraid.org/](https://freedns.afraid.org/)

* Authenticate to GCP:

  ```bash
  # create separate gcloud config configuration to not mess with your current config
  gcloud config configuration create dev-ghost
  # init your gcloud command, select us-central1-a as zone for example
  make google-authentication
  ```

## Usage

* Deploy Ghost

    ```bash
    # show Ghost Terraform deployment plan (development option)
    # agree on bucket creation for Terraform state
    make run-ghost ENV=dev MODE=plan

    # when plan looks good, perform deployment
    make run-ghost ENV=dev MODE=apply

    # configure A record
    # for stage/dev/ghost/terragrunt.hcl#input.url DNS domain
    # with IP returned from the deployment output of: ghost_glb_public_ip
    # in your DNS domain provider
    ```

* Deploy Post Management

  * Go to your site configured here: [stage/dev/ghost/terragrunt.hcl#input.url](stage/dev/ghost/terragrunt.hcl)

  * Follow [Ghost Authentication](https://ghost.org/docs/admin-api/javascript/#authentication) procedure to retrieve Admin API key and Content API key

  ```bash
  # store your ADMIN_KEY and CONTENT_KEY as environment variables
  # (add space so that this command will be not stored in your .bash_history)
   export ADMIN_KEY='...'
   export CONTENT_KEY='...'
  # show Ghost Terraform deployment plan (development option)
  # agree on bucket creation for Terraform state
  make run-posts-management ENV=dev MODE=plan

  # when plan looks good, perform deployment
  make run-posts-management ENV=dev MODE=apply

  # when you wish to remove all posts invoke:
  make remove-all-posts ENV=dev
  ```
