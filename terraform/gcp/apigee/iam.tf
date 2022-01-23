# Dedicated service account for the Apigee MIG server instance
resource "google_service_account" "apigee" {
  account_id   = "apigee-${var.env}-${google_apigee_organization.org.name}-sa"
  display_name = "Service account for Apigee resources ${var.env}-${google_apigee_organization.org.name}"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "apigee-oslogin-user" {
  project = var.project

  role   = "roles/compute.osLogin"
  member = "serviceAccount:${google_service_account.apigee.email}"
}

# allows to gsutil cp both directions
resource "google_project_iam_member" "apigee-mig-gs" {
  project = var.project

  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.apigee.email}"
}

# to let OpsAgent send logs
resource "google_project_iam_member" "apigee-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.apigee.email}"
}

# to let OpsAgent expose metrics
resource "google_project_iam_member" "apigee-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.apigee.email}"
}
