# allow to SSH to any instance within network and from IAP
resource "google_compute_firewall" "private-allow-ssh" {
  name        = "${google_compute_network.private.name}-allow-ssh"
  description = "Allow SSH traffic to any VM within ${google_compute_network.private.name} VPC and from IAP"
  network     = google_compute_network.private.name
  direction   = "INGRESS"
  project     = var.project
  # 35.235.240.0/20 represents adresses used for IAP
  source_ranges = ["35.235.240.0/20", "10.0.0.0/8"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # Ommiting target_* assumes that firewall rule is applied on all VM within network
  # target_service_accounts = [google_service_account.gke-sa.email]]
  # target_tags = [ "..." ]
}

# allow to HTTP to any instance within network
resource "google_compute_firewall" "private-allow-http" {
  name          = "${google_compute_network.private.name}-allow-http"
  description   = "Allow HTTP traffic to any VM within ${google_compute_network.private.name} VPC"
  network       = google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["10.0.0.0/8"]

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443", "8443", "6443"]
  }
  # Ommiting target_* assumes that firewall rule is applied on all VM within network
  # target_service_accounts = [google_service_account.gke-sa.email]]
  # target_tags = [ "..." ]
}
