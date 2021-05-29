resource "google_compute_network" "private" {
  name                    = "private-vpc"
  auto_create_subnetworks = "false"
}

# For private GKE cluster
# Primary ip_cidr_range has to belong to rfc1918 and it is used for GKE nodes
# Secondary adress ranges can be non-rfc1918, but it complicates NAT:
# https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_reserved_ip_ranges
resource "google_compute_subnetwork" "private1" {
  name          = "private-subnet-${var.regions[0]}"
  region        = var.regions[0]
  network       = google_compute_network.private.name
  ip_cidr_range = "10.10.0.0/16"

  private_ip_google_access = true
  # TODO seems not working?
  private_ipv6_google_access = true

  # max pods: 32,766
  secondary_ip_range {
    range_name    = "pod-range-0"
    ip_cidr_range = "100.64.0.0/17"
  }

  secondary_ip_range {
    range_name    = "pod-range-1"
    ip_cidr_range = "100.66.0.0/17"
  }
  # max svcs: 4,094
  secondary_ip_range {
    range_name    = "svc-range-0"
    ip_cidr_range = "100.96.0.0/20"
  }

  secondary_ip_range {
    range_name    = "svc-range-1"
    ip_cidr_range = "100.96.16.0/20"
  }
}

resource "google_compute_subnetwork" "private2" {
  name          = "private-subnet-${var.regions[1]}"
  region        = var.regions[1]
  network       = google_compute_network.private.name
  ip_cidr_range = "10.14.0.0/16"

  private_ip_google_access = true
  # TODO seems not working?
  private_ipv6_google_access = true

  secondary_ip_range {
    range_name    = "pod-range-0"
    ip_cidr_range = "100.68.0.0/17"
  }

  secondary_ip_range {
    range_name    = "pod-range-1"
    ip_cidr_range = "100.70.0.0/17"
  }

  secondary_ip_range {
    range_name    = "svc-range-0"
    ip_cidr_range = "100.96.32.0/20"
  }

  secondary_ip_range {
    range_name    = "svc-range-1"
    ip_cidr_range = "100.96.48.0/20"
  }
}


resource "google_compute_subnetwork" "private-l7lb-1" {
  provider = google-beta

  name          = "private-l7lb-subnetwork-${var.regions[0]}"
  ip_cidr_range = "10.13.0.0/24"
  region        = var.regions[0]
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.private.name

  project = var.project
}


resource "google_compute_subnetwork" "private-l7lb-2" {
  provider = google-beta

  name          = "private-l7lb-subnetwork-${var.regions[1]}"
  ip_cidr_range = "10.13.1.0/24"
  region        = var.regions[1]
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
  network       = google_compute_network.private.name

  project = var.project
}
