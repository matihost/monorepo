resource "google_compute_global_address" "http_lb" {
  name          = "http_lb"
  address_type  = "EXTERNAL"
  ip_version    = "IPV4"
  prefix_length = "0"
}


resource "google_compute_global_forwarding_rule" "http_lb_fr" {
  name                  = "http-external-gke-shared1-dev"
  ip_address            = google_compute_global_address.http_lb.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.http_lb_https_proxy.self_link
}


resource "google_compute_target_https_proxy" "http_lb_https_proxy" {
  name             = "istio-ext-http-target-proxy"
  quic_override    = "NONE"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert_id.self_link]
  url_map          = google_compute_url_map.http_lb_url_map.self_link
}


resource "google_compute_url_map" "http_lb_url_map" {
  default_service = google_compute_backend_service.istio-http.self_link
  name            = "istio-ext"
}


resource "google_compute_backend_service" "istio-http" {
  affinity_cookie_ttl_sec = "0"

  backend {
    balancing_mode               = "RATE"
    capacity_scaler              = "1"
    group                        = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${local.zone}/networkEndpointGroups/neg-istio-external-http"
    max_connections              = "0"
    max_connections_per_endpoint = "0"
    max_connections_per_instance = "0"
    max_rate                     = "0"
    max_rate_per_endpoint        = "1000"
    max_rate_per_instance        = "0"
    max_utilization              = "0"
  }

  connection_draining_timeout_sec = "300"
  enable_cdn                      = "false"
  health_checks                   = [google_compute_health_check.istio.self_link]
  load_balancing_scheme           = "EXTERNAL"

  log_config {
    enable      = "true"
    sample_rate = "1"
  }

  name             = "istio-http"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "NONE"
  timeout_sec      = "30"
}
