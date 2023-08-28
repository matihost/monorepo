# # TODO add SLO alerting, notifying channels

resource "google_monitoring_service" "keycloak" {
  project  = var.project
  for_each = { for instance in var.instances : instance.region => instance }

  service_id   = "${local.name}-${each.key}-svc"
  display_name = "Cloud Run ${local.name}-${each.key} Monitoring Service"

  user_labels = {
    project_id = var.project
    location   = each.key
    service    = "${local.name}-${each.key}"
  }

  basic_service {
    service_type = "CLOUD_RUN"
    service_labels = {
      location     = each.key
      service_name = "${local.name}-${each.key}"
    }
  }
}


resource "google_monitoring_slo" "keycloak" {
  project  = var.project
  for_each = { for instance in var.instances : instance.region => instance }

  service = google_monitoring_service.keycloak[each.key].service_id

  slo_id = "${local.name}-${each.key}-slo"

  display_name = "SLO for ${local.name}-${each.key} Cloud Run"

  goal            = 0.99
  calendar_period = "DAY"

  basic_sli {
    latency {
      threshold = "1s"
    }
  }
}
