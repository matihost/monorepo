resource "google_compute_global_forwarding_rule" "istio-tcp" {
  ip_address            = google_compute_global_address.istio-tcp.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  name                  = "bare-tcp"
  port_range            = "443-443"
  target                = google_compute_target_tcp_proxy.istio-over-tcp-target-proxy.self_link
}

resource "google_compute_global_address" "istio-tcp" {
  address_type  = "EXTERNAL"
  ip_version    = "IPV4"
  name          = "istio-tcp"
  prefix_length = "0"
}


resource "google_compute_target_tcp_proxy" "istio-over-tcp-target-proxy" {
  backend_service = google_compute_backend_service.istio-https-backend.self_link
  name            = "istio-over-tcp-target-proxy"
  proxy_header    = "NONE"
}


resource "google_compute_backend_service" "istio-https-backend" {
  affinity_cookie_ttl_sec = "0"

  backend {
    balancing_mode               = "CONNECTION"
    capacity_scaler              = "1"
    group                        = "https://www.googleapis.com/compute/v1/projects/${var.project}/zones/${local.zone}/networkEndpointGroups/neg-istio-external-https"
    max_connections              = "0"
    max_connections_per_endpoint = "100"
    max_connections_per_instance = "0"
    max_rate                     = "0"
    max_rate_per_endpoint        = "0"
    max_rate_per_instance        = "0"
    max_utilization              = "0"
  }

  connection_draining_timeout_sec = "300"
  enable_cdn                      = "false"
  health_checks                   = [google_compute_health_check.istio.self_link]
  load_balancing_scheme           = "EXTERNAL"

  log_config {
    enable      = "false"
    sample_rate = "0"
  }

  name             = "istio-over-https"
  port_name        = "https"
  protocol         = "TCP"
  session_affinity = "NONE"
  timeout_sec      = "30"
}
