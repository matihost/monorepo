# Terraform :: GKE

Setup private standalone Google Kubernetes Engine (GKE) instance in own provisioned VPC.

The script provisions:

* Create CloudDNS private `shared.dev.gke.testing` zone and deploy ExternalDNS for Ingress/Svs auto DNS record provisioning.

Uses GCP resources eligible to [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits) __only__.

Warning:

Since GKE is zonal, cluster setup may fail with temporal error like:

* workflow identity not present yet (this is actually a bug on GKE side)
* after cluster creation - unable to connect to it to setup cluster-config

In each case, just wait couple of minutes, and repeat cluster creation script (as it is idempotent) until scripts pass.

## Prerequisites

* Logged to Google Console Account

  ```bash
  make google-authentication
  ```

* Latest Terraform installed

* Prerequisites Terraform run once:
  * [../gcp-network-setup](../gcp-network-setup) to setup VPC and subnetwork
  * [../gcp-repository](../gcp-repository) to setup container Artifact Registry
  * (Optionally) [../gcp-kms](../gcp-kms) to setup KMS keyring and keys for encyption and use later `encrypt_etcd` set ti `true`)
  * (Optionally) [../gcp-bigquery-dataset](../gcp-bigquery-dataset) to setup BigQuery dataset and use later `bigquery_metering` set to `true` to use setup cluster with BigQuery metering

## Usage

```bash

# setup GKE cluster
make run [CLUSTER_NAME=shared1-dev] [MODE=apply]

# opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
make open-tunnel

# creates ~/.kube/config context to for GKE cluster
make setup-kubecontext [CLUSTER_NAME=shared1-dev]

# sample url to Ingress exposed internally
curl -x http://localhost:8888 -ksSL https://yyyy.shared1.dev.gke.testing

# show Terraform state
make show-state
```
