
resource "google_service_account" "configsync-sa" {
  account_id   = "gke-config-sync-sa"
  display_name = "Service Account which is used by ConfigSync workflow in GKE"
}


resource "google_project_iam_member" "configsync-sa-source-reader" {
  project = var.project

  role   = "roles/source.reader"
  member = "serviceAccount:${google_service_account.configsync-sa.email}"
}

resource "google_service_account_iam_member" "configsync-sa-source-reader-workflowidentity" {
  service_account_id = google_service_account.configsync-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, "config-management-system", "importer")
}
