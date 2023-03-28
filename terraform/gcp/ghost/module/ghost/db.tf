# TODO tune setup for var.ha == true
# TODO handle user management and password taken from GCP Secret

resource "google_sql_database_instance" "ghost" {
  database_version = "MYSQL_8_0_26"
  instance_type    = "CLOUD_SQL_INSTANCE"
  name             = local.regional_name
  project          = var.project
  region           = var.region

  settings {
    activation_policy = "ALWAYS"
    availability_type = var.ha ? "REGIONAL" : "ZONAL"

    backup_configuration {
      backup_retention_settings {
        retained_backups = "7"
        retention_unit   = "COUNT"
      }

      binary_log_enabled             = "true"
      enabled                        = "true"
      location                       = "us"
      point_in_time_recovery_enabled = "false"
      start_time                     = "19:00"
      transaction_log_retention_days = "7"
    }

    connector_enforcement       = "NOT_REQUIRED"
    deletion_protection_enabled = "false"
    disk_autoresize             = "true"
    disk_autoresize_limit       = "0"
    disk_size                   = var.ha ? "100" : "20"
    disk_type                   = var.ha ? "PD_HDD" : "PD_SSD"

    ip_configuration {
      enable_private_path_for_google_cloud_services = "false"
      ipv4_enabled                                  = "true"
      require_ssl                                   = "false"
    }


    maintenance_window {
      day  = "6"
      hour = "22"
    }

    tier = "db-custom-2-8192"
  }

  depends_on = [
    google_project_service.required
  ]
}


resource "google_sql_database" "ghost" {
  charset         = "utf8mb4"
  collation       = "utf8mb4_0900_ai_ci"
  deletion_policy = "DELETE"
  instance        = google_sql_database_instance.ghost.name
  name            = "ghost"
  project         = var.project
}

resource "google_sql_user" "user" {
  name     = "ghost"
  instance = google_sql_database_instance.ghost.name
  type     = "BUILT_IN"
  password = "todoUseGcpSecretHere"
}
