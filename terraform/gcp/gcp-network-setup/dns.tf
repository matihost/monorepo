resource "google_dns_managed_zone" "main-zone" {
  provider = google-beta
  project  = var.project

  force_destroy = true

  name        = var.env
  dns_name    = "${var.env}.gcp.testing."
  description = "Main private DNS zone"
  labels = {
    owner = "private-vpc"
  }

  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.private.id
    }
    networks {
      network_url = data.google_compute_network.default.id
    }
  }
}

resource "google_dns_policy" "allow-inbound-query-forwarding" {
  name = "allow-inbound-query-forwarding"

  # https://cloud.google.com/dns/docs/policies#list-in-entrypoints
  # When an inbound server policy applies to a VPC network,
  # Cloud DNS creates a set of regional internal IP addresses that serve as destinations to which your on-premises systems or name resolvers can send DNS requests.
  # These addresses serve as entry points to the name resolution order of your VPC network.
  # Google Cloud firewall rules do not apply to the regional internal addresses that act as entry points for inbound forwarders.
  # Cloud DNS accepts TCP and UDP traffic on port 53 automatically.
  # Each inbound forwarder accepts and receives queries from Cloud VPN tunnels or Cloud Interconnect attachments (VLANs) in the same region as the regional internal IP address.
  #
  # To list the set of regional internal IP addresses that serve as entry points for inbound forwarding, run the compute addresses list command:
  # gcloud compute addresses list --filter='purpose = "DNS_RESOLVER"' --format='csv(address, region, subnetwork)'
  enable_inbound_forwarding = true

  enable_logging = false

  networks {
    network_url = google_compute_network.private.id
  }
  networks {
    network_url = data.google_compute_network.default.id
  }
}

output "dns_resolvers" {
  value = "gcloud compute addresses list --filter='purpose = \"DNS_RESOLVER\"' --format='csv(address, region, subnetwork)'"
}
