locals {
  gha_name = "gha-${substr(var.gh_repo_owner, 0, 10)}-${substr(var.gh_repo_name, 0, 13)}"
}

data "google_project" "current" {
}

resource "google_service_account" "gha" {
  account_id   = local.gha_name
  display_name = "Service Account for GitHub Actions access for edition"
}

resource "google_service_account_iam_member" "gha-workflow-binding" {
  service_account_id = google_service_account.gha.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.pool.workload_identity_pool_id}/attribute.repository/${var.gh_repo_owner}/${var.gh_repo_name}"
}

# It gives access to all GKE clusters
# To give only selected roles to GSA use K8S RBAC
# Run the kubectl create rolebinding command from Applications in the same cluster
# and use --user=gha-matihost-monorepo@matihack6.iam.gserviceaccount.com instead of the --service-account flag.
resource "google_project_iam_member" "gha-ghe-binding" {
  project = var.project

  role   = "roles/container.developer"
  member = "serviceAccount:${google_service_account.gha.email}"
}

# so that can access GCP GS
resource "google_project_iam_member" "gha-gs-access" {
  project = var.project

  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gha.email}"
}

# so that can access GCP Artifacts
resource "google_project_iam_member" "gha-artifacts-access" {
  project = var.project

  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.gha.email}"
}
