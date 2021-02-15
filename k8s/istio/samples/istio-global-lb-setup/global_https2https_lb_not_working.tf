# Error from LB Logs:
#
# jsonPayload: {
# @type: "type.googleapis.com/google.cloud.loadbalancing.type.LoadBalancerLogEntry"
# statusDetails: "failed_to_connect_to_backend"
# }
#
resource "google_compute_global_address" "https_lb" {
  name          = "https_lb"
  address_type  = "EXTERNAL"
  ip_version    = "IPV4"
  prefix_length = "0"
}


resource "google_compute_global_forwarding_rule" "https_lb_fr" {
  name                  = "http-external-gke-shared1-dev"
  ip_address            = google_compute_global_address.https_lb.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.https_lb_https_proxy.self_link
}


resource "google_compute_target_https_proxy" "https_lb_https_proxy" {
  name             = "istio-ext-https-target-proxy"
  quic_override    = "NONE"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert_id.self_link]
  url_map          = google_compute_url_map.https_lb_url_map.self_link
}


resource "google_compute_url_map" "https_lb_url_map" {
  default_service = google_compute_backend_service.istio-https.self_link
  name            = "istio-ext"
}


resource "google_compute_backend_service" "istio-https" {
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

  name                = "istio"
  timeout_sec         = "5"
  unhealthy_threshold = "3"
}
