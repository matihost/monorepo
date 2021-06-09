resource "google_dns_managed_zone" "cluster-zone" {
  provider = google-beta
  project  = var.project

  force_destroy = true

  name        = "${var.cluster_name}-${var.env}"
  dns_name    = "${var.cluster_name}.${var.env}.gcp.testing."
  description = "DNS for ingresses/svs exposed from GKE ${local.gke_name} managed manually"
  labels = {
    owner = "gke-${local.gke_name}"
  }

  visibility = "private"
  private_visibility_config {
    networks {
      network_url = data.google_compute_network.private-gke.id
    }
    networks {
      network_url = data.google_compute_network.default.id
    }
  }
}


# External DNS resources
resource "google_dns_managed_zone" "external-dns-cluster-zone" {
  provider = google-beta
  project  = var.project

  force_destroy = true

  name        = "gke-${var.cluster_name}-${var.env}"
  dns_name    = "gke.${var.cluster_name}.${var.env}.gcp.testing."
  description = "DNS for ingresses/svs exposed from GKE ${local.gke_name} managed by ExternalDNS"
  labels = {
    owner = "gke-${local.gke_name}"
  }

  visibility = "private"
  private_visibility_config {
    networks {
      network_url = data.google_compute_network.private-gke.id
    }
    networks {
      network_url = data.google_compute_network.default.id
    }
  }
}

# Tell the parent zone where to find the DNS records for this zone by adding the corresponding NS records there.
# Adding NS record is of type NS and is disallowed in private managed zones
# It only matters for public zones
#
# resource "google_dns_record_set" "ns" {
#   name         = google_dns_managed_zone.external-dns-cluster-zone.dns_name
#   managed_zone = google_dns_managed_zone.cluster-zone.name
#   type         = "NS"
#   ttl          = 300

#   rrdatas = google_dns_managed_zone.external-dns-cluster-zone.name_servers
# }
