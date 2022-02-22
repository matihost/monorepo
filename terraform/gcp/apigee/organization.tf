
data "google_kms_key_ring" "us-keyring" {
  name     = "us-keyring"
  location = "us"
}

data "google_kms_crypto_key" "apigee-key" {
  name     = "apigee-us-db-enc-key"
  key_ring = data.google_kms_key_ring.us-keyring.id
}

resource "google_project_service_identity" "apigee-sa" {
  provider = google-beta

  project = data.google_project.current.project_id
  service = google_project_service.apigee.service
}

resource "google_kms_crypto_key_iam_binding" "apigee-sa-keyuser" {
  crypto_key_id = data.google_kms_crypto_key.apigee-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.apigee-sa.email}",
  ]
}

resource "google_apigee_organization" "org" {
  analytics_region                     = var.region
  display_name                         = data.google_client_config.current.project
  description                          = "Apigee organization for GCP project: ${data.google_client_config.current.project}"
  project_id                           = data.google_client_config.current.project
  authorized_network                   = data.google_compute_network.private.id
  runtime_database_encryption_key_name = data.google_kms_crypto_key.apigee-key.id
  runtime_type                         = "CLOUD"


  depends_on = [
    google_kms_crypto_key_iam_binding.apigee-sa-keyuser,
  ]
}
