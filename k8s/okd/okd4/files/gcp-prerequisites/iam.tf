resource "google_service_account" "okd-installer" {
  account_id   = "okd-installer"
  display_name = "Service Account to install OKD"
}

resource "google_project_iam_member" "editor-rolebinding" {
  project = var.project

  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}


# Minimum set of roles to SSH to machine as SA
resource "google_project_iam_member" "okd-installer-ssh-user" {
  project = var.project

  role   = "roles/compute.osAdminLogin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-service-account-user" {
  project = var.project

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-iap-accessor-user" {
  project = var.project

  role   = "roles/iap.tunnelResourceAccessor"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}


# OKD roles needed for OKD installer
# https://github.com/openshift/installer/blob/master/docs/user/gcp/iam.md
resource "google_project_iam_member" "okd-installer-compute-admin" {
  project = var.project

  role   = "roles/compute.admin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-dns-admin" {
  project = var.project

  role   = "roles/dns.admin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-security-admin" {
  project = var.project

  role   = "roles/iam.securityAdmin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-service-account-admin" {
  project = var.project

  role   = "roles/iam.serviceAccountAdmin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-storage-admin" {
  project = var.project

  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}

resource "google_project_iam_member" "okd-installer-service-account-key-admin" {
  project = var.project

  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "serviceAccount:${google_service_account.okd-installer.email}"
}



resource "google_service_account_key" "okd-installer-key" {
  service_account_id = google_service_account.okd-installer.name
}

resource "google_secret_manager_secret" "okd-installer-secret" {
  secret_id = "sa-okd-installer-key"

  replication {
    automatic = true
  }

  depends_on = [
    google_project_service.apis
  ]
}

resource "google_secret_manager_secret_version" "okd-installer-secret-value" {
  secret = google_secret_manager_secret.okd-installer-secret.id

  secret_data = base64decode(google_service_account_key.okd-installer-key.private_key)
}
