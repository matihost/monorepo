# Minimal GCP recommended network setup with private subnet

The following scripts creates:

* private VPC with subnets spanning in regions. Subnets can be used as base for GKE deploy as they contains additional ip ranges for pods and svc addresses.

* Bastion VM - in single region -  with HTTP proxy installed on 8787 port

* Cloud Nat in all regions for internet access from private VPC regions

* Private Service Access - so that Google Manages Services like CloudSQL or Apigee, can be accessible via internal ip (w/o need to use external ip)

## Prerequisites

* Logged to Google Console Account

  ```bash
  make google-authentication
  ```

* (Optionally, but recommended) Enable required GCP APIs. Deployments ensure that particular API is enabled first, but Google often claims that API is enabled, but later on deployment claims it is not yet, and several minutes waiting is really required that API is truly enabled on GCP side.
  The list of required APIs: [Compute](https://console.cloud.google.com/apis/library/compute.googleapis.com), [Service Networking](https://console.cloud.google.com/apis/library/servicenetworking.googleapis.com), [Dns](https://console.cloud.google.com/apis/library/dns.googleapis.com)

* Latest OpenTofu and Terragrunt installed

## Usage

```bash
# setup private networking (VPC, NAT, Private Service Access and bastion host with proxy)
make run [ENV=dev] [MODE=apply]

# connect to Bastion via Cloud IAP
make ssh

# show state
make show-state

# terminates all GCP resources created with apply task
make destroy
```
