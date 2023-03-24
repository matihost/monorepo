# Service Account which is used by Workstations VMs
resource "google_service_account" "workstations-sa" {
  account_id   = "workstations-sa"
  display_name = "Service Account which is used by Workstations VMs"
}

resource "google_project_iam_member" "workstations-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}

resource "google_project_iam_member" "workstations-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}


resource "google_project_iam_member" "workstations-traces-writer" {
  project = var.project

  role   = "roles/cloudtrace.agent"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}


# also needed to send metrics, permits write-only access to resource metadata provide permissions needed by agents to send metadata
resource "google_project_iam_member" "workstations-metrics-metadata-writer" {
  project = var.project

  role   = "roles/stackdriver.resourceMetadata.writer"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}


# so that  workstations cluster can access images from its own GCP project (gcr.io/project-id)
resource "google_project_iam_member" "workstations-gcr-access" {
  project = var.project

  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}

# so that  workstations cluster can access GCP Artifacts
resource "google_project_iam_member" "workstations-artifacts-access" {
  project = var.project

  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.workstations-sa.email}"
}

resource "google_workstations_workstation_config" "default" {
  provider = google-beta
  project  = var.project

  workstation_config_id  = "default-config"
  workstation_cluster_id = google_workstations_workstation_cluster.private.workstation_cluster_id
  location               = var.region



  host {
    gce_instance {
      # service_account             = google_service_account.workstations-sa.id
      machine_type                = "n2d-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = true
      pool_size                   = 0
      shielded_instance_config {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
      confidential_instance_config {
        enable_confidential_compute = true
      }
    }
  }

  container {
    # https://cloud.google.com/workstations/docs/preconfigured-base-images
    image = "code-oss"
  }
}


resource "google_workstations_workstation" "default" {
  provider = google-beta
  project  = var.project

  workstation_id         = "workstation"
  workstation_config_id  = google_workstations_workstation_config.default.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.private.workstation_cluster_id
  location               = var.region

}
