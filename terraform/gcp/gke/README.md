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

### TL;DR

```bash
# run
make <TASK>

#with one of the following tags:
#
#ensure-cluster-shared1         create/update cluster shared1-dev in us-central1-a
#ensure-cluster-shared2         create/update cluster shared2-dev in us-east1-b
#destroy-cluster-shared1        destroy cluster shared1-dev in us-central1-a
#destroy-cluster-shared2        destroy cluster shared2-dev in us-east1-b
#scale-down-shared1             scale down to 0 nodes cluster shared1-dev in us-central1-a
#scale-down-shared2             scale down to 0 nodes cluster shared2-dev in us-east1-b
#scale-up-shared1               scale up to 1 nodes cluster shared1-dev in us-central1-a
#scale-up-shared2               scale up to 1 node cluster shared2-dev in us-east1-b
```

### Detailed usage

```bash
# setup GKE cluster and other accompanied resources and expose Kube Master API via ExternalIP
# but limits access only from this laptop public ip
make apply
# which is equivalent for
make apply CLUSTER_NAME=shared REGION=us-central1 ZONE_LETTER=a MASTER_CIDR := "172.16.0.32/28"

# opens tunnel via bastion, export HTTP_PROXY=http://localhost:8888 to use it in the shell
make open-tunnel

# creates ~/.kube/config context to for GKE cluster
make setup-kubecontext

# create GKE cluster w/o public IP for Master Kube API
# GKE API would available only internall or via bastion node
make MASTER_PUBLIC_IP=false MASTER_ACCESS_CIRDS="[]"

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
