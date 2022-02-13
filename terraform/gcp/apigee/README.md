# ApigeeX

Deploy managed, trial version of Apigee in GCP (ApigeeX).

ApigeeX installation consists of:

* Apigee Organization - with the same name as GCP project

* Single Apigee Instance in a zone.  Regional or more instances require paid Apigee subscription.

* Single Apigee Environment called `dev`

* Single Apigee Environment Group consisting `dev` Environment visible via DNS `api.dev.gcp.testing` and provided DNS via EXTERNAL_DNS variable.

* GCP DNS record `api.dev.gcp.testing` pointing to Apigee Instance private IP.
  So that Apigee instance is available via <https://api.dev.gcp.testing> from within VPC.

Apart from Apigee infrastructure:

* `proxies` directory contains sample Apigee API Proxies and automation to deploy them

Limitations:

* TODO sample provider VMs are hardcoded in proxies definition, use KVM with IP (or ideally deploy DNS entry for target servers VMs)

* add removal of old revision when latest is deployed to keep only max ~10 old revisions per proxy ApigeeX does not have cleaning old proxy revision rule,

## Prerequisites

* Terraform `../gcp-network-setup` has been deployed
* Terraform `../gcp-kms` has been deployed

## Usage

```bash
# deploy ApigeeX, usage: make apply EXTERNAL_DNS=api.some.com [DEBUG=true APPROVE=false]
make apply EXTERNAL_DNS=api.some.com

# deploys sample application being targetServers for Api proxies in proxies directory
make deploy-exchanges-provider
make deploy-echoserver

# deploy all API proxies from proxies directory (sample exchanges and echoserver) on Apigee
make deploy-api-proxies

# test API over Apigee
make test-echoserver DNS=api.some.com
make test-exchangerate DNS=api.some.com
```
