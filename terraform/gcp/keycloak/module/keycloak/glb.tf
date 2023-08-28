#TODO add TLS termination to GLB
#TODO add Cloud Armor, add WAF(?)

resource "google_compute_global_address" "keycloak" {
  name         = local.name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_global_forwarding_rule" "keycloak" {
  ip_address            = google_compute_global_address.keycloak.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = local.name
  port_range            = "443-443"
  project               = var.project
  target                = google_compute_target_https_proxy.keycloak.self_link
}


resource "google_compute_target_https_proxy" "keycloak" {
  name             = local.name
  project          = var.project
  quic_override    = "NONE"
  ssl_certificates = [google_compute_ssl_certificate.keycloak.self_link]
  url_map          = google_compute_url_map.keycloak.self_link
}

resource "google_compute_ssl_certificate" "keycloak" {

  name_prefix = "${local.name}-"
  private_key = var.tls_key
  certificate = var.tls_crt

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "keycloak" {
  default_service = google_compute_backend_service.keycloak.self_link
  name            = local.name
  project         = var.project
}


resource "google_compute_backend_service" "keycloak" {
  affinity_cookie_ttl_sec = "0"

  dynamic "backend" {
    for_each = { for instance in var.instances : instance.region => instance }
    iterator = it

    content {
      balancing_mode               = "UTILIZATION"
      capacity_scaler              = "1"
      group                        = google_compute_region_network_endpoint_group.keycloak[it.key].self_link
      max_connections              = "0"
      max_connections_per_endpoint = "0"
      max_connections_per_instance = "0"
      max_rate                     = "0"
      max_rate_per_endpoint        = "0"
      max_rate_per_instance        = "0"
      max_utilization              = "0"
    }
  }

  cdn_policy {
    cache_key_policy {
      include_host         = "true"
      include_protocol     = "true"
      include_query_string = "true"
    }

    cache_mode                   = "CACHE_ALL_STATIC"
    client_ttl                   = "3600"
    default_ttl                  = "3600"
    max_ttl                      = "86400"
    negative_caching             = "false"
    serve_while_stale            = "0"
    signed_url_cache_max_age_sec = "0"
  }

  connection_draining_timeout_sec = "0"
  enable_cdn                      = "true"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"

  log_config {
    enable      = "true"
    sample_rate = "1"
  }

  name             = local.name
  port_name        = "http"
  project          = var.project
  protocol         = "HTTPS"
  session_affinity = "CLIENT_IP"
  timeout_sec      = "30"
}
