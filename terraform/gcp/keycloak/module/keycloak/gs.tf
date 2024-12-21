resource "google_storage_bucket" "keycloak" {
  name          = "${var.project}-${local.regional_name}"
  force_destroy = true
  # GCP free tier GS is free only with regional class in some US regions
  location                    = var.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = true
}

# GCS does not support adding .well-known/acme-challenge/ entries
#
# Error uploading object .well-known/acme-challenge/...:
# googleapi: Error 400: ACME HTTP challenges are not supported.
#
# To expose Let's Encrypt location it needs to be done on LB routing level with path rewrite option.
#
# The .well-known/acme-challenge/verification_file needs to placed in the root GS bucket directory.


resource "google_compute_backend_bucket" "keycloak" {
  name        = local.name
  description = "For static ACME HTTP challenges content exposure only"
  bucket_name = google_storage_bucket.keycloak.name
  enable_cdn  = false
}


# Grant allUsers public read access to the bucket's objects
resource "google_storage_bucket_iam_member" "keycloak-public-access" {
  bucket = google_storage_bucket.keycloak.self_link
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
