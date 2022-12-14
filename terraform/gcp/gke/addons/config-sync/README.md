# Addons :: Standalone Config Sync

Installs [Standalone Config Sync](https://cloud.google.com/anthos-config-management/docs/how-to/installing-kubectl) on GKE

## Prerequisites

* Logged to Google Console Account

* GKE cluster created

* Latest Terraform installed

* Prerequisites Terraform run once per GCP project:

  * `cd prerequisites && make run` to setup GCP Git repository and necessary IAM bindings

## Usage

```bash

# installs Standalone Config Sync on GKE
make apply CLUSTER_NAME=shared1

# uninstalls Standalone Config Sync
make destroy
```
