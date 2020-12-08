resource "google_dns_managed_zone" "gke-zone" {
  provider = google-beta
  project  = var.project

  name        = "${var.cluster_name}-${var.env}-gke"
  dns_name    = "${var.cluster_name}.${var.env}.gke."
  description = "DNS for ingresses/svs exposed from GKE ${local.gke_name}"
  labels = {
    owner = "gke-${local.gke_name}"
  }

  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.private-gke.id
    }
    networks {
      network_url = data.google_compute_network.default.id
    }
  }
}
