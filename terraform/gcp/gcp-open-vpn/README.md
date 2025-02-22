# Open VPN to GCP Private VPC

Cloud VPN only supports site-to-site IPsec VPN connectivity, subject to the requirements listed in this section. It does not support client-to-gateway scenarios. In other words, Cloud VPN doesn't support use cases where client computers need to "dial in" to a VPN by using client VPN software.

To overcome this this repo setup OpenVPN Gateway instance in GCP private VPC (VPC created via `..\gcp-network-setup`). So that is OpenVPN client can "dial in" into GCP private VPC.

Supports:

* updates client ip routes with VPC network ranges, also allows access VPN client network from VPC itself

* access to GCP internal DNS - to query internal VPC CloudDNS entries. For example: `nslookup private-vpc-bastion.us-central1-a.c.PROJECT_NAME.internal 169.254.169.254` does work.

* allows CloudDNS forward DNS queries for on-premise/vpn client DNS zone

TODOs/Limitations:

* To resolve GCP PriveDNS you need to update VPN client machine DNS setting to use Cloud DNS nameserver for Cloud hosted private zones. That requires using DNS nameserver on client which forward queries for particular zone to other nameserver.

  * For GCP it requires creating [Cloud DNS inbound policy](https://cloud.google.com/dns/docs/policies#list-in-entrypoints) which exposes DNS nameserver IP in each subnetwork.
  The possible IP which VPN can use as DNS servers are:

  ```bash
  gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'
  ```

  Then configure DNS server on VPN client side forward queries to CloudDNS proxy DNS server. For Bind add the following zone with valid IP address to /etc/bind/named.conf.local:

  ```
  zone "gcp.testing" {
      type forward;
      forward only;
      forwarders { 10.10.0.yyy; };
  };
  // Main zone for GCP Workstations
  zone "cloudworkstations.dev" {
      type forward;
      forward only;
      forwarders { 10.10.0.yyy; };
  };
  ```

  The IP should be takend from subnetwork and region where VPN server is deployed.

## Prerequisites

* Terraform [../gcp-network-setup](../gcp-network-setup) has been deployed

## Usage

```bash
# deploy OpenVPN Gateway in GCP VPC
make run [ENV=dev] [MODE=apply]
# depending on machine size the initialization of OpenVPN service may take several minutes

# create target/client.ovpn file needed to connect to VPN
# mode is either all (default), aka all trafic goes via VPN
# or private - when only GCP VPC traffic routed via VPN
make get-client-ovpn [VPN_MODE=all]

# connect to to VPN, press Ctrl+C to disconnect
# mode is either all (default), aka all trafic goes via VPN
# or private - when only GCP VPC traffic routed via VPN
make connect-to-vpn [VPN_MODE=all]

# Troubleshooting:
# ssh to the machine
make ssh
sudo journalctl --follow
sudo systemctl status openvpn-server@server.service
ls -l /etc/openvpn/server

# check Systemd openvpn-server@server.service status on OpenVPN instance
make check-vpn-service-status
```

## OpenVPN Client

Get client.ovpn file:

```bash
# create target/client.ovpn file needed to connect to VPN
# mode is either all (default), aka all trafic goes via VPN
# or private - when only GCP VPC traffic routed via VPN
make get-client-ovpn [VPN_MODE=all]
```

For Windows and Mac - download and install [OpenVPN Connect](https://openvpn.net/client/)

On Linux: go to Setting / Network / VPN

and import target/client.ovpn file.
