// Service Account which is used by GKE Nodes
resource "google_service_account" "gke-sa" {
  account_id   = "gke-sa"
  display_name = "Service Account which is used by GKE Nodes"
}


resource "google_project_iam_binding" "gke-log-writer" {
  role = "roles/logging.logWriter"

  members = [
    "serviceAccount:${google_service_account.gke-sa.email}",
  ]
}

resource "google_project_iam_binding" "gke-metrics-writer" {
  role = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.gke-sa.email}",
  ]
}



// Dedicated service account for the Bastion instance
resource "google_service_account" "bastion" {
  account_id   = "${local.gke_name}-bastion-sa"
  display_name = "Service account for GKE ${local.gke_name} bastion instance"
}

resource "google_project_iam_binding" "bastion-gke-admin" {
  role = "roles/container.clusterAdmin"

  members = [
    "serviceAccount:${google_service_account.bastion.email}",
  ]
}
