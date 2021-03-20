# Open VPN to GCP Private VPC

Cloud VPN only supports site-to-site IPsec VPN connectivity, subject to the requirements listed in this section. It does not support client-to-gateway scenarios. In other words, Cloud VPN doesn't support use cases where client computers need to "dial in" to a VPN by using client VPN software.

To overcome this this repo setup OpenVPN Gateway instance in GCP private VPC (VPC created via `..\gcp-network-setup`). So that is OpenVPN client can "dial in" into GCP private VPC.

Supports:

* updates client ip routes with VPC network ranges, also allows access VPN client network from VPC itself

* access to GCP internal DNS - to query internal VPC CloudDNS entries. For example: `nslookup private-vpc-bastion.us-central1-a.c.PROJECT_NAME.internal 169.254.169.254` does work.

TODOs/Limitations:

* update VPN client machine DNS setting to use Cloud DNS nameserver for Cloud hosted private zones. That requires using DNS nameserver on client which forward queries for particular zone to other nameserver.

  * For GCP it requires creating [Cloud DNS inbound policy](https://cloud.google.com/dns/docs/policies#list-in-entrypoints) which exposes DNS nameserver IP in each subnetwork.
  The possible IP which VPN can use as DNS servers are: `gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'`.

  Then configure DNS server on VPN client side forward queries to CloudDNS proxy DNS server. For Bind add:

  ```
  zone "gcp.testing" {
      type forward;
      forward only;
      forwarders { 10.10.0.yyy; };
  };
  ```

  The IP should be takend from subnetwork and region where VPN server is deployed.

## Prerequisites

* Terraform `../gcp-network-setup` has been deployed

## Usage

```bash
# deploy OpenVPN Gateway in GCP VPC
make apply

# connect to to VPN, press Ctrl+C to disconnect
./connect-to-vpn.sh
```
