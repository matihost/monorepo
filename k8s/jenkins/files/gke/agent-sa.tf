resource "google_service_account" "agent-sa" {
  account_id   = "${var.gke_namespace}-agent"
  display_name = "Service Account which is used by Jenkins Agent workflow in GKE"
}

resource "google_project_iam_member" "agent-sa-image-pushing" {
  project = var.project

  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.agent-sa.email}"
}

# WorkloadIdentity of external-dns KSA to act as GSA
resource "google_service_account_iam_member" "agent_gsa2k8ssa" {
  service_account_id = google_service_account.agent-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = format("serviceAccount:%s.svc.id.goog[%s/%s]", var.project, var.gke_namespace, "${var.gke_namespace}-agent")
}
