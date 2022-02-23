resource "google_service_account" "editor" {
  account_id   = "editor"
  display_name = "Service Account for various edition"
}

resource "google_project_iam_member" "editor-rolebinding" {
  project = var.project

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.editor.email}"
}


# Minimum set of roles to SSH to machine as SA
resource "google_project_iam_member" "editor-ssh-user" {
  project = var.project

  role   = "roles/compute.osAdminLogin"
  member = "serviceAccount:${google_service_account.editor.email}"
}

resource "google_project_iam_member" "editor-service-account-user" {
  project = var.project

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.editor.email}"
}

resource "google_project_iam_member" "editor-iap-accessor-user" {
  project = var.project

  role   = "roles/iap.tunnelResourceAccessor"
  member = "serviceAccount:${google_service_account.editor.email}"
}


resource "google_service_account_key" "editor-key" {
  service_account_id = google_service_account.editor.name
}

resource "google_secret_manager_secret" "editor-secret" {
  secret_id = "sa-editor-key"

  replication {
    automatic = true
  }

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_secret_manager_secret_version" "editor-secret-value" {
  secret = google_secret_manager_secret.editor-secret.id

  secret_data = base64decode(google_service_account_key.editor-key.private_key)
}
