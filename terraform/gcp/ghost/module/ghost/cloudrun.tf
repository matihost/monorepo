# TODO image has to be mirrored in gcp gcr.io
# TODO maybe run.googleapis.com/cloudsql-instances should be part of variables to allow DR
# TODO tune startup and livenes probes
# TODO canary deployment for cloud run
# TODO for dev env do not disable oauth
# TODO maybe separate cloud run instance for admin purposes,
#   for client traffic cloud run instances disable /ghost site (aka admin)
#   do it on CloudArmor/WAF?

resource "google_cloud_run_service" "ghost" {
  provider = google-beta
  project  = var.project
  for_each = { for instance in var.instances : "${instance.region}" => instance }


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
      service_account_name  = google_service_account.ghost.email
      containers {
        image = each.value.image
        ports {
          name           = "http1"
          container_port = 2368
        }
        env {
          name  = "database__client"
          value = "mysql"
        }
        env {
          name  = "database__connection__socketPath"
          value = "/cloudsql/${google_sql_database_instance.ghost.connection_name}"
        }
        env {
          name  = "database__connection__user"
          value = google_sql_user.user.name
        }
        env {
          name  = "database__connection__password"
          value = google_sql_user.user.password
        }
        env {
          name  = "database__connection__database"
          value = google_sql_database.ghost.name
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
            path = "/ghost/api/admin/site"
          }
        }
        liveness_probe {
          initial_delay_seconds = 10
          timeout_seconds       = 2
          period_seconds        = 10
          failure_threshold     = 3
          http_get {
            path = "/ghost/api/admin/site"
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/sessionAffinity"       = "true",
        "autoscaling.knative.dev/minScale"         = "1",
        "autoscaling.knative.dev/maxScale"         = "100",
        "run.googleapis.com/execution-environment" = "gen2",
        "run.googleapis.com/cpu-throttling"        = "true",
        "run.googleapis.com/startup-cpu-boost"     = "true",
        "run.googleapis.com/cloudsql-instances"    = google_sql_database_instance.ghost.connection_name,
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
      metadata.0.annotations,
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
  for_each = { for instance in var.instances : "${instance.region}" => instance }

  location    = google_cloud_run_service.ghost[each.key].location
  service     = google_cloud_run_service.ghost[each.key].name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_compute_region_network_endpoint_group" "ghost" {
  project  = var.project
  for_each = { for instance in var.instances : "${instance.region}" => instance }

  name                  = google_cloud_run_service.ghost[each.key].name
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  cloud_run {
    service = google_cloud_run_service.ghost[each.key].name
  }
}
