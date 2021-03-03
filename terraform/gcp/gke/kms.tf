# KMS keyring and encyption key has to exist before
# The cannot be recreated

data "google_kms_key_ring" "gke-keyring" {
  count    = var.encrypt_etcd ? 1 : 0
  name     = "${var.region}-keyring"
  location = var.region # GKE does not support global location for keyring
}

# etcd encryption key
data "google_kms_crypto_key" "gke-etcd-enc-key" {
  count    = var.encrypt_etcd ? 1 : 0
  name     = "gke-etcd-enc-key"
  key_ring = data.google_kms_key_ring.gke-keyring[0].self_link
}

# allow GKE itself (represented as below sa) to use key for encyption
resource "google_kms_crypto_key_iam_binding" "gke-etcd-enc-key-binding" {
  count         = var.encrypt_etcd ? 1 : 0
  crypto_key_id = data.google_kms_crypto_key.gke-etcd-enc-key[0].self_link
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}
