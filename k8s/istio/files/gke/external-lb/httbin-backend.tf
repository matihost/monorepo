# Assumes samples
resource "google_compute_health_check" "httpbin-https-heathcheck" {
  count    = var.enable_external_ingress_node_pool ? 1 : 0
  provider = google-beta
  project  = var.project

  check_interval_sec = "10"
  healthy_threshold  = "2"

  https_health_check {
    host               = "http.external.gke.shared1.dev.gcp.testing"
    port_specification = "USE_SERVING_PORT"
    proxy_header       = "NONE"
    request_path       = "/get"
  }

  log_config {
    enable = "false"
  }

  name                = "httpbin-get"
  timeout_sec         = "5"
  unhealthy_threshold = "3"
}

resource "google_compute_backend_service" "httpbin-https" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  affinity_cookie_ttl_sec = "0"

  backend {
    balancing_mode               = "RATE"
    capacity_scaler              = "1"
    group                        = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${local.zone}/networkEndpointGroups/neg-istio-external-https"
    max_connections              = "0"
    max_connections_per_endpoint = "0"
    max_connections_per_instance = "0"
    max_rate                     = "0"
    max_rate_per_endpoint        = "100"
    max_rate_per_instance        = "0"
    max_utilization              = "0"
  }

  connection_draining_timeout_sec = "300"
  enable_cdn                      = "false"
  health_checks                   = [google_compute_health_check.httpbin-https-heathcheck[0].self_link]
  load_balancing_scheme           = "EXTERNAL_MANAGED"

  log_config {
    enable      = "true"
    sample_rate = "1"
  }

  name             = "httpbin-https"
  port_name        = "https"
  protocol         = "HTTPS"
  session_affinity = "NONE"
  timeout_sec      = "30"
}
