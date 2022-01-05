# ApigeeX

Deploy managed, trial version of Apigee in GCP (ApigeeX).

ApigeeX installation consists of:

* Apigee Organization - with the same name as GCP project

* Single Apigee Instance in a zone.  Regional or more instances require paid Apigee subscription.

* Single Apigee Environment called `dev`

* Single Apigee Environment Group consisting `dev` Environment visible via DNS `api.dev.gcp.testing`.

* GCP DNS record `api.dev.gcp.testing` pointing to Apigee Instance private IP.
  So that Apigee instance is available via <https://api.dev.gcp.testing> from within VPC.

## Prerequisites

* Terraform `../gcp-network-setup` has been deployed
* Terraform `../gcp-kms` has been deployed

## Usage

```bash
# deploy OpenVPN Gateway in GCP VPC
make apply

# setup Open VPN and forwards DNS in GCP to client VPN network DNS nameserver
make apply-with-dns-forwarding ZONE=vpnclient.zone.com IP=10.8.0.2

# connect to to VPN, press Ctrl+C to disconnect
make connect-to-vpn
# or
./connect-to-vpn.sh
```
