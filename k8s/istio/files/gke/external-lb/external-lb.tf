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
  load_balancing_scheme = "EXTERNAL_MANAGED"
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

  host_rule {
    hosts        = ["http.external.gke.shared1.dev.gcp.testing"]
    path_matcher = "path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_backend_service.httpbin-https[0].self_link
    name            = "path-matcher-1"
  }
}
