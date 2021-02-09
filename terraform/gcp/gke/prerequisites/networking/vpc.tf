resource "google_compute_network" "private" {
  name                    = "private-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "private" {
  name          = "private-subnet-${var.region}"
  region        = var.region
  network       = google_compute_network.private.name
  ip_cidr_range = "10.10.0.0/16"

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "private-pod-range"
    ip_cidr_range = "10.11.0.0/16"
  }

  secondary_ip_range {
    range_name    = "private-svc-range"
    ip_cidr_range = "10.12.0.0/16"
  }
}


resource "google_compute_subnetwork" "private-l7lb" {
  provider = google-beta

  name          = "private-l7lb-subnetwork"
  ip_cidr_range = "10.13.0.0/24"
  region        = var.region
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.private.name

  project = var.project
}
