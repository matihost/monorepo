# Terraform :: Minimal GCP recommended network setup with private subnet

Terraform scripts creating:

* private VPC with two subnets spanning in two regions (us-central1 and us-east1). Both subnets can be used as base for GKE deploy as they contains additional ip ranges for pods and svc adressess.

* Bastion VM

* Cloud Nat in both regions for internet access from private VPC regions

* Private Service Access - so that Google Manages Services like CloudSQL or Apigee, can be accessible via internal ip (w/o need to use external ip)

## Prerequisites

* Logged to Google Console Account

```bash
make google-authentication
```

* Latest Terraform installed

## Usage

```bash
# setup VPC, NAT and bastion
make apply

# show Terraform state
make show-state

# terminates all GCP resources created with apply task
make destroy
```
