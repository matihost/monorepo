# TODO tune setup for var.ha == true
# TODO handle user management and password taken from GCP Secret

resource "google_sql_database_instance" "keycloak" {
  database_version = "POSTGRES_17"
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
    disk_type                   = var.ha ? "PD_SSD" : "PD_HDD"

    ip_configuration {
      enable_private_path_for_google_cloud_services = "false"
      ipv4_enabled                                  = "true"
      ssl_mode                                      = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }


    maintenance_window {
      day  = "6"
      hour = "22"
    }

    tier    = "db-f1-micro"
    edition = "ENTERPRISE"
  }

  depends_on = [
    google_project_service.required
  ]
}


resource "google_sql_database" "keycloak" {
  charset         = "UTF8"
  collation       = "en_US.UTF8"
  deletion_policy = "DELETE"
  instance        = google_sql_database_instance.keycloak.name
  name            = "keycloak"
  project         = var.project
}


resource "random_string" "pass" {
  length  = 16
  special = false
}


resource "google_secret_manager_secret" "pass" {
  secret_id = "db-${local.regional_name}-keycloak-pass"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "pass_secret_version" {
  secret      = google_secret_manager_secret.pass.id
  secret_data = random_string.pass.result
}


resource "google_sql_user" "user" {
  name     = "keycloak"
  instance = google_sql_database_instance.keycloak.name
  type     = "BUILT_IN"
  password = random_string.pass.result
}
