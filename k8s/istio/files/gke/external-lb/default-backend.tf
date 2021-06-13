# Assumes samples
# ./sample-http-server.sh gke shared1-dev
# has been deployed
# aka httpbin deployment along with VirtualService pointing to external Gateway

resource "google_compute_ssl_certificate" "external-wildcard" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name_prefix = "external-wildcard-"
  private_key = var.external_wildcard_tls_key
  certificate = var.external_wildcard_tls_crt

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "istio-https" {
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
  health_checks                   = [google_compute_health_check.istio-status.self_link]
  load_balancing_scheme           = "EXTERNAL"

  log_config {
    enable      = "true"
    sample_rate = "1"
  }

  name             = "istio-over-https"
  port_name        = "https"
  protocol         = "HTTPS"
  session_affinity = "NONE"
  timeout_sec      = "30"
}


resource "google_compute_health_check" "istio-status" {
  provider = google-beta

  check_interval_sec = "10"
  healthy_threshold  = "2"

  http_health_check {
    port               = "15021"
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/healthz/ready"
  }

  log_config {
    enable = "false"
  }

  name                = "istio-status"
  timeout_sec         = "5"
  unhealthy_threshold = "3"
}


resource "google_dns_record_set" "external-ingress-wildcard-entry" {
  provider = google-beta
  count    = var.enable_external_ingress_node_pool ? 1 : 0
  project  = var.project

  managed_zone = data.google_dns_managed_zone.gke-dns-zone.name
  name         = "${var.external_wildcard_cn}."
  type         = "A"
  rrdatas      = [google_compute_global_address.https_lb[0].address]
  ttl          = 86400
}
