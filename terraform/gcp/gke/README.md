# Terraform :: Sample GKE Instance

Setup private Google Kubernetes Engine (GKE) instance in own provisioned VPC.

It also provisions:

* NAT Gateway to allow GKE cluster access the Internet.

* Bastion VM with TinyProxy to allow access to Kube API from laptop

Use  GCP resources eliglible to [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits) __only__.

## Prerequisites

* Logged to Google Console Account

```bash
make google-authentication
```

* Latest Terraform installed

## Usage

```bash
# setup GKE cluster and other accompanied resources
make apply

# to setup SSH tunnel to proxy located on bastion VM and configure kube commands to access private GKE cluster freely
source access-gke.sh



# show Terraform state
make show-state

# terminates all GCP resources created with apply task
make destroy
```
