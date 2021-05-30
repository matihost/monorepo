resource "google_compute_firewall" "gke-accept-gatekeeper-webhook" {
  name          = "${local.gke_name}-accept-gatekeeper-webhook"
  description   = "Allow traffic to GKE nodes for gatekeeper webhook from GKE Master Nodes"
  network       = data.google_container_cluster.gke.network
  direction     = "INGRESS"
  project       = var.project
  source_ranges = [data.google_container_cluster.gke.private_cluster_config[0].master_ipv4_cidr_block]

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  target_service_accounts = [local.gke_nodes_sa]
}
