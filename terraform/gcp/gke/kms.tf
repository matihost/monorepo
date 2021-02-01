# KMS keyring and encyption key has to exist before
# The cannot be recreated

data "google_kms_key_ring" "gke-keyring" {
  name     = "${local.gke_name}-keyring"
  location = var.region # GKE does not support global location for keyring
}

# etcd encryption key
data "google_kms_crypto_key" "gke-etcd-enc-key" {
  name     = "gke-etcd-enc-key"
  key_ring = data.google_kms_key_ring.gke-keyring.self_link
}

# allow GKE itself (represented as below sa) to use key for encyption
resource "google_kms_crypto_key_iam_binding" "gke-etcd-enc-key-binding" {
  crypto_key_id = data.google_kms_crypto_key.gke-etcd-enc-key.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}
