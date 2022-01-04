# KMS for cluster encryption
resource "google_kms_key_ring" "keyring" {
  project  = var.project
  name     = "${var.region}-keyring"
  location = var.region # GKE does not support global location for keyring

  # KMS keys are un-deletable and there is no way to not omit them upo terraform destrory
  # https://github.com/hashicorp/terraform/issues/23547
  #
  # Import it if the already exists:
  # terraform import google_kms_key_ring.keyring us-central1/shared-dev-keyring
  #
  # Prevent destroy only ensures to no remove them accidentally
  # To destoy all resources expept this one remove it from state:
  # terraform state rm google_kms_key_ring.keyring
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_project_service.kms-apis
  ]
}

# etcd encryption key
resource "google_kms_crypto_key" "gke-etcd-enc-key" {
  name            = "gke-etcd-enc-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "31536000s" # 365 days

  # KMS keys are un-deletable and there is no way to not omit them upo terraform destroy
  # https://github.com/hashicorp/terraform/issues/23547
  #
  # Import it if the already exists:
  # terraform import google_kms_crypto_key.gke-etcd-enc-key us-central1/us-central1-keyring/gke-etcd-enc-key
  #
  # Prevent destroy only ensures to no remove them accidentally
  # To destoy all resources except this one remove it from state:
  # terraform state rm google_kms_crypto_key.gke-etcd-enc-key
  lifecycle {
    prevent_destroy = true
  }
}


# etcd encryption key
resource "google_kms_crypto_key" "apigee-enc-key" {
  name            = "apigee-enc-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "31536000s" # 365 days

  # Import it if the already exists:
  # terraform import google_kms_crypto_key.apigee-enc-key us-central1/us-central1-keyring/gke-etcd-enc-key
  lifecycle {
    prevent_destroy = true
  }
}
