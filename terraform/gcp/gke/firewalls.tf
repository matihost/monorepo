resource "google_compute_firewall" "gke-accept-lb" {
  name          = "${local.gke_name}-accept-lb"
  description   = "Allow traffic to GKE nodes from GCP LoadBalancers"
  network       = data.google_compute_network.private-gke.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  target_service_accounts = [google_service_account.gke-sa.email]
}

resource "google_compute_firewall" "gke-accept-istio-webhook" {
  name          = "${local.gke_name}-accept-istio-webhook"
  description   = "Allow traffic to GKE nodes for istio webhook from GKE Master Nodes"
  network       = data.google_compute_network.private-gke.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = [var.master_cidr]

  allow {
    protocol = "tcp"
    ports    = ["15017"]
  }

  target_service_accounts = [google_service_account.gke-sa.email]
}
