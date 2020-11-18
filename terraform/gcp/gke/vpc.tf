resource "google_compute_network" "private-gke" {
  name                    = "private-gke-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "private-gke" {
  name          = "private-gke-subnet"
  region        = var.region
  network       = google_compute_network.private-gke.name
  ip_cidr_range = "10.10.0.0/16"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "private-gke-pod-range"
    ip_cidr_range = "10.11.0.0/16"
  }

  secondary_ip_range {
    range_name    = "private-gke-svc-range"
    ip_cidr_range = "10.12.0.0/16"
  }
}


resource "google_compute_subnetwork" "private-gke-l7lb" {
  provider = google-beta

  name          = "private-gke-l7lb-subnetwork"
  ip_cidr_range = "10.13.0.0/24"
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.private-gke.name

  project = var.project
}
