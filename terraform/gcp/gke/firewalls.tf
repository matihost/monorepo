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
