resource "google_compute_ssl_certificate" "external-wildcard" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name_prefix = "external-wildcard-"
  private_key = var.external_wildcard_tls_key
  certificate = var.external_wildcard_tls_crt

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_address" "https_lb" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name         = "external-https-lb"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}


resource "google_compute_global_forwarding_rule" "https_lb_fr" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name                  = "external-https-lb"
  ip_address            = google_compute_global_address.https_lb[0].address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.https_lb_https_proxy[0].self_link
}


resource "google_compute_target_https_proxy" "https_lb_https_proxy" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  name             = "istio-ext-https-target-proxy"
  quic_override    = "NONE"
  ssl_certificates = [google_compute_ssl_certificate.external-wildcard[0].self_link]
  url_map          = google_compute_url_map.https_lb_url_map[0].self_link
}


resource "google_compute_url_map" "https_lb_url_map" {
  count = var.enable_external_ingress_node_pool ? 1 : 0

  default_service = google_compute_backend_service.istio-https[0].self_link
  name            = "istio-ext"
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
  check_interval_sec = "10"
  healthy_threshold  = "2"

  http_health_check {
    port               = "15021"
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
    request_path       = "/healthz/ready"
  }

  name                = "istio-status"
  timeout_sec         = "5"
  unhealthy_threshold = "3"
}
