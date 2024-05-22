# TODO image has to be mirrored in gcp gcr.io
# TODO maybe run.googleapis.com/cloudsql-instances should be part of variables to allow DR
# TODO tune startup and livenes probes
# TODO canary deployment for cloud run

resource "google_cloud_run_service" "keycloak" {
  provider = google-beta
  project  = var.project
  for_each = { for instance in var.instances : instance.region => instance }


  name     = "${local.name}-${each.key}"
  location = each.key
  metadata {
    annotations = {
      "run.googleapis.com/client-name"          = "terraform",
      "run.googleapis.com/binary-authorization" = "default",
      "run.googleapis.com/ingress"              = "all",
      "run.googleapis.com/ingress-status"       = "all"
    }
  }

  autogenerate_revision_name = true

  template {
    spec {
      container_concurrency = 80
      timeout_seconds       = 60
      service_account_name  = google_service_account.keycloak.email
      containers {
        image = each.value.image
        ports {
          name           = "http1"
          container_port = 8080
        }
        env {
          name  = "KEYCLOAK_ADMIN"
          value = google_sql_user.user.name
        }
        env {
          name  = "KEYCLOAK_ADMIN_PASSWORD"
          value = google_sql_user.user.password
        }
        env {
          name  = "KC_DB_URL"
          value = "jdbc:postgresql:///${google_sql_database.keycloak.name}?cloudSqlInstance=${google_sql_database_instance.keycloak.connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
        }
        env {
          name  = "KC_DB_USERNAME"
          value = google_sql_user.user.name
        }
        env {
          name  = "KC_DB_PASSWORD"
          value = google_sql_user.user.password
        }
        env {
          name  = "url"
          value = var.url
        }
        resources {
          limits = {
            cpu    = "2"
            memory = "1Gi"
          }
        }
        startup_probe {
          initial_delay_seconds = 20
          timeout_seconds       = 2
          period_seconds        = 5
          failure_threshold     = 10
          http_get {
            path = "/realms/master"
          }
        }
        liveness_probe {
          initial_delay_seconds = 10
          timeout_seconds       = 2
          period_seconds        = 10
          failure_threshold     = 3
          http_get {
            path = "/realms/master"
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/sessionAffinity"       = "true",
        # Set to 0 to reduce
        # Idle Min-Instance CPU Allocation Time and Idle Min-Instance Memory Allocation Time
        # One idle instance costs 20 $ / month
        "autoscaling.knative.dev/minScale"         = "0",
        "autoscaling.knative.dev/maxScale"         = "5",
        "run.googleapis.com/execution-environment" = "gen2",
        "run.googleapis.com/cpu-throttling"        = "true",
        "run.googleapis.com/startup-cpu-boost"     = "true",
        "run.googleapis.com/cloudsql-instances"    = google_sql_database_instance.keycloak.connection_name,
        "run.googleapis.com/client-name"           = "terraform"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
    ]
  }

  depends_on = [
    google_project_service.required
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  project  = var.project
  for_each = { for instance in var.instances : instance.region => instance }

  location    = google_cloud_run_service.keycloak[each.key].location
  service     = google_cloud_run_service.keycloak[each.key].name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_compute_region_network_endpoint_group" "keycloak" {
  project  = var.project
  for_each = { for instance in var.instances : instance.region => instance }

  name                  = google_cloud_run_service.keycloak[each.key].name
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  cloud_run {
    service = google_cloud_run_service.keycloak[each.key].name
  }
}
