data "google_project" "current" {
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "${replace(var.region, "-", "_")}_dataset"
  friendly_name               = "BigQuery dataset for ${var.region} analizys"
  description                 = "BigQuery dataset for ${var.region} analizys"
  location                    = var.region   # Should be in sync with GKE location so preffered regional
  default_table_expiration_ms = 24 * 3600000 # 1 day

  labels = {
    env = var.env
  }

  access {
    role          = "OWNER" # other roles WRITER, READER
    user_by_email = google_service_account.bqowner.email
  }

  # so that GKE clusters can write to datasets: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-usage-metering#create-dataset
  access {
    role          = "WRITER"
    user_by_email = "service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
  }

}

resource "google_service_account" "bqowner" {
  account_id   = "bq-${var.region}-owner"
  display_name = "Owner of BigQuery ${var.region} datasets"
}
