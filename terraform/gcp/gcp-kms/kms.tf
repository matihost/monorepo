locals {
  regions = toset([
    "us-central1",
    "us-east1",
    "europe-central2"
  ])

  keyring_locations = toset(concat(tolist(local.regions), ["us"]))
}

# KMS for cluster encryption
resource "google_kms_key_ring" "keyring" {
  for_each = local.keyring_locations

  project  = var.project
  name     = "${each.key}-keyring"
  location = each.key

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


# etcd encryption key, GKE does not support global location for keyring, GKE supports regional keyrings for ETCD
resource "google_kms_crypto_key" "gke-etcd-enc-key" {
  for_each = local.regions

  name            = "gke-${each.key}-etcd-enc-key"
  key_ring        = google_kms_key_ring.keyring[each.key].id
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


# Apigee Org db encryption key
resource "google_kms_crypto_key" "apigee-us-db-enc-key" {
  name            = "apigee-us-db-enc-key"
  key_ring        = google_kms_key_ring.keyring["us"].id
  rotation_period = "31536000s" # 365 days

  lifecycle {
    prevent_destroy = true
  }
}

# Apigee instance dick encription keys
resource "google_kms_crypto_key" "apigee-disk-enc-key" {
  for_each = local.regions

  name            = "apigee-${each.key}-disk-enc-key"
  key_ring        = google_kms_key_ring.keyring[each.key].id
  rotation_period = "31536000s"
  lifecycle {
    prevent_destroy = true
  }
}
