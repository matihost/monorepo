locals {
  workstation_cluster_id = "${var.region}-${var.env}"
}

resource "google_workstations_workstation_cluster" "private" {
  provider = google-beta
  project  = var.project

  workstation_cluster_id = "${var.region}-${var.env}"
  display_name           = "GKE for workstations in ${var.region}"
  network                = data.google_compute_network.private.id
  subnetwork             = data.google_compute_subnetwork.private.id
  location               = var.region


  private_cluster_config {
    enable_private_endpoint = true
  }

  labels = {
    region = var.region
    env    = var.env
  }
}

#  Private Service Connect (PSC) for Workstation Cluster

resource "google_compute_address" "private_workstation_psc_address" {
  name         = "psc-work-private-${var.region}"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.private.id
  project      = var.project
  region       = var.region
}

resource "google_compute_forwarding_rule" "private_service_connect_forwarding_rule" {
  name                  = "psc-fwrd-rule-work-private-${var.region}"
  load_balancing_scheme = ""
  region                = var.region
  project               = var.project
  ip_address            = google_compute_address.private_workstation_psc_address.id
  target                = google_workstations_workstation_cluster.private.private_cluster_config[0].service_attachment_uri
  network               = data.google_compute_network.private.id
}


# DNS for workstation

resource "google_dns_managed_zone" "work-zone" {
  provider = google-beta
  project  = var.project

  force_destroy = true

  name        = "workstation-cluster-${local.workstation_cluster_id}"
  dns_name    = "${google_workstations_workstation_cluster.private.private_cluster_config[0].cluster_hostname}."
  description = "DNS zone for ${google_workstations_workstation_cluster.private.workstation_cluster_id}"
  labels = {
    owner = google_workstations_workstation_cluster.private.workstation_cluster_id
  }

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = data.google_compute_network.private.id
    }
  }
}


resource "google_dns_record_set" "private_workstation_psc_dns_record" {
  provider = google-beta
  project  = var.project

  managed_zone = google_dns_managed_zone.work-zone.name
  name         = "*.${google_workstations_workstation_cluster.private.private_cluster_config[0].cluster_hostname}."
  type         = "A"
  rrdatas      = [google_compute_address.private_workstation_psc_address.address]
  ttl          = 86400
}
