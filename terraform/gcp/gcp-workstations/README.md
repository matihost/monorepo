# GCP Workstations

Deploys private GCP Workstations in private VPC

Workstations installation consists of:

* Workstation Cluster - cluster is in private mode and exposed to private VPC via PSC.

Limitations:

* Workstation Configuration - no support from Terraform GPC Provider yet

* Workstations - no support from Terraform GPC Provider yet

## Prerequisites

* [GCP Network Setup](../gcp-network-setup) terraform has been deployed

* Since cluster is private, access is only from within GCP VPC. To access from other souces setup VPN etc. For example: [gcp-open-vpn](../gcp-open-vpn/) has been deployed and your laptop connect to opne VPN and ensure `cloudworkstations.dev` DNS are forwarded GCP DNS nameservices in proper VPC.

## Usage

```bash
# usage: make run [MODE=apply/plan/destroy]
#
# deploys GCP Workstations infrastructure
make run

# destroys GCP Workstations infrastructure
make run MODE=destroy
```
