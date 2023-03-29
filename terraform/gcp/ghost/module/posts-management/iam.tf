resource "google_service_account" "ghost-cf" {
  account_id   = "${local.name}-cf"
  display_name = "Service Account for ${local.name} Cloud Function activities Ghost deployment"
}

# TODO limit role assignment to minimum for Least Priviledge Principal rule
resource "google_project_iam_member" "ghost-cf-rolebinding" {
  project = var.project

  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.ghost-cf.email}"
}
