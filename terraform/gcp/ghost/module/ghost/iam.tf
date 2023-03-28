resource "google_service_account" "ghost" {
  account_id   = local.name
  display_name = "Service Account for ${local.name} Ghost deployment"
}

# TODO limit role assignment to minimum for Least Priviledge Principal rule
resource "google_project_iam_member" "ghost-rolebinding" {
  project = var.project

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.ghost.email}"
}
