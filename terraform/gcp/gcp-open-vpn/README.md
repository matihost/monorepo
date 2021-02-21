# Open VPN to GCP Private VPC

Cloud VPN only supports site-to-site IPsec VPN connectivity, subject to the requirements listed in this section. It does not support client-to-gateway scenarios. In other words, Cloud VPN doesn't support use cases where client computers need to "dial in" to a VPN by using client VPN software.

To overcome this this repo setup OpenVPN Gateway instance in GCP private VPC (VPC created via `..\gcp-network-setup`). So that is OpenVPN client can "dial in" into GCP private VPC.

Supports:

* updates client ip routes with VPC network ranges, also allows access VPN client network from VPC itself

* access to GCP internal DNS - to query internal VPC CloudDNS entries. For example: `nslookup private-vpc-bastion.us-central1-a.c.PROJECT_NAME.internal 169.254.169.254` does work.

TODOs/Limitations:

* update VPN client DNS to use `169.254.169.254` for `internal` subzone and any zone hostes in GCP interanl CloudDNS. For Bind add:

  ```
  zone "internal" {
      type forward;
      forward only;
      forwarders { 169.254.169.254; };
  };
  ```

## Prerequisites

* Terraform `../gcp-network-setup` has been deployed

## Usage

```bash
# deploy OpenVPN Gateway in GCP VPC
make apply

# connect to to VPN, press Ctrl+C to disconnect
./connect-to-vpn.sh
```
