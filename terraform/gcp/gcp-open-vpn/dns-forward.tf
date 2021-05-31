resource "google_dns_managed_zone" "onpremise_dns_zone_forward" {
  count       = var.onpremise_dns_zone_forward.zone != "" ? 1 : 0
  name        = var.onpremise_dns_zone_forward.zone
  description = "Forwarding DNS zone: ${var.onpremise_dns_zone_forward.zone} to on premise ${var.onpremise_dns_zone_forward.dns_ip}"
  dns_name    = "${var.onpremise_dns_zone_forward.zone}."

  forwarding_config {
    target_name_servers {
      forwarding_path = "private"
      ipv4_address    = var.onpremise_dns_zone_forward.dns_ip
    }
  }

  labels = {
    owner = "private-vpc"
  }

  visibility = "private"
  private_visibility_config {
    networks {
      network_url = data.google_compute_network.private.id
    }
  }
}
