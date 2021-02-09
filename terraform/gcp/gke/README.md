# Terraform :: Sample GKE Instance

Setup private Google Kubernetes Engine (GKE) instance in own provisioned VPC.

It also provisions:

* NAT Gateway to allow GKE cluster access the Internet.

* Bastion VM with TinyProxy to allow access to internal Ingresses resources from laptop (and Kube API in case enable_private_endpoint is se to true).

* Setup `restricted` PodSecurityPolicty to allow non priviledge deployment out of the box

* Create CloudDNS private `gke.shared.dev.` zone and deploy ExternalDNS for Ingress/Svs auto DNS record provisioning.

Use  GCP resources eliglible to [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier#free-tier-usage-limits) __only__.

## Prerequisites

* Logged to Google Console Account

```bash
make google-authentication
```

* Latest Terraform installed

* Prerequisites Terraform run once:
  * `cd prerequisites\networking && make apply` to setup VPC and subnetwork
  * (Optionally) `cd prerequisites\kms && make apply` to setup KMS keyring and keys for encyption. Then run `make apply ENCRYPT_ETCD=true` to use setup cluster with ETCD encryption

## Usage

```bash
# setup GKE cluster and other accompanied resources and expose Kube Master API via ExternalIP
# but limits access only from this laptop public ip
make apply

# opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
make open-tunnel

# creates ~/.kube/config context to for GKE cluster
make setup-kubecontext

# create GKE cluster w/o public IP for Master Kube API
make ACCESS_FROM_LAPTOP=false

# in that case in order to access it from laptop it requires to setup SSH tunnel to proxy located on bastion VM and configure kube commands to access private GKE cluster freely
source access-gke.sh

# sample url to Ingress exposed internally
curl -x http://localhost:8888 -ksSL https://yyyy.gke.shared.dev

# show Terraform state
make show-state

# terminates all GCP resources created with apply task
# Warning: Ensure you shut down all apps and their GCP resources (mainly ingresses, dns record sets)
# Because it will prevent cluster from build shutdown completely
make destroy
```
