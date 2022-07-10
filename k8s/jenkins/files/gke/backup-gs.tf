resource "google_storage_bucket" "jenkins-data" {
  name          = "${var.project}-${var.gke_namespace}-jenkins-server-data"
  force_destroy = true
  # GCP free tier GS is free only with regional class in some US regions
  location = "US-CENTRAL1"
  # location      = var.region

  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      # keep  24 versions of a file, aka max 24 backups
      num_newer_versions = 24
    }
    action {
      type = "Delete"
    }
  }
}
