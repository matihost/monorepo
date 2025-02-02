// Service Account which is used by GKE Nodes
resource "google_service_account" "gke-sa" {
  account_id   = "${local.gke_name}-gke-sa"
  display_name = "Service Account which is used by GKE Nodes"
}

resource "google_project_iam_member" "gke-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

resource "google_project_iam_member" "gke-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}


resource "google_project_iam_member" "gke-traces-writer" {
  project = var.project

  role   = "roles/cloudtrace.agent"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}


# also needed to send metrics, permits write-only access to resource metadata provide permissions needed by agents to send metadata
resource "google_project_iam_member" "gke-metrics-metadata-writer" {
  project = var.project

  role   = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}


# so that  GKE cluster can access images from its own GCP project (gcr.io/project-id)
resource "google_project_iam_member" "gke-gcr-access" {
  project = var.project

  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}

# so that  GKE cluster can access GCP Artifacts
resource "google_project_iam_member" "gke-artifacts-access" {
  project = var.project

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}



# so that  GKE cluster can access GCP Source repositories - required by Config Sync
resource "google_project_iam_member" "gke-source-reader" {
  project = var.project

  role   = "roles/source.reader"
  member = "serviceAccount:${google_service_account.gke-sa.email}"
}
