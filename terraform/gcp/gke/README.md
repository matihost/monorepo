# Terraform :: Sample GKE Instance

Setup private Google Kubernetes Engine (GKE) instance in own provisioned VPC.

It also provisions:

* NAT Gateway to allow GKE cluster access the Internet.

* Bastion VM with TinyProxy to allow access to internal Ingresses resources from laptop (and Kube API in case enable_private_endpoint is se to true).

Use  GCP resources eliglible to [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits) __only__.

* Setup Cloud private zone and resources for ExternalDNS deployment

## Prerequisites

* Logged to Google Console Account

```bash
make google-authentication
```

* Latest Terraform installed

## Usage

```bash
# setup GKE cluster and other accompanied resources and expose Kube Master API via ExternalIP
# but limits access only from this laptop public ip
make apply

# populate kubecotx with credentials to cluster
gcloud container clusters get-credentials shared-dev --zone us-central1-a

# opens tunnel via bastion hpst, export HTTP_PROXY=http://localhost:8888 to use it in the shell
make setup-tunnel-via-bastion

# create GKE cluster w/o public IP for Master Kube API
make ACCESS_FROM_LAPTOP=false

# in that case in order to access it from laptop it requires to setup SSH tunnel to proxy located on bastion VM and configure kube commands to access private GKE cluster freely
source access-gke.sh

# sample url to Ingress exposed internally
curl -x http://localhost:8888 -ksSL https://yyyy.gke.shared.dev

# show Terraform state
make show-state

# terminates all GCP resources created with apply task
make destroy
```
