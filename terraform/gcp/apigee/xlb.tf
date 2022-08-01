resource "google_compute_global_address" "apigee-xlb" {
  name         = "apigee-${var.env}-${google_apigee_organization.org.name}"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_global_forwarding_rule" "apigee-xlb-https" {
  ip_address            = google_compute_global_address.apigee-xlb.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "api-${var.env}-${google_apigee_organization.org.name}-https"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.apigee-xlb-https.self_link
}

resource "google_compute_target_https_proxy" "apigee-xlb-https" {
  name             = "api-${var.env}-${google_apigee_organization.org.name}-https"
  quic_override    = "NONE"
  ssl_certificates = [google_compute_ssl_certificate.apigee-xlb.self_link]
  url_map          = google_compute_url_map.apigee-mig.self_link
}

resource "google_compute_ssl_certificate" "apigee-xlb" {
  name_prefix = "${local.external_dns_name}-"
  private_key = file("${path.module}/${local.external_tls_key_filename}")
  certificate = file("${path.module}/${local.external_tls_crt_filename}")

  lifecycle {
    create_before_destroy = true
  }
}


resource "google_compute_url_map" "apigee-mig" {
  default_service = google_compute_backend_service.apigee-mig.self_link
  name            = "mig-${var.env}-${google_apigee_organization.org.name}"
}

#  Http2Https Redirect
resource "google_compute_global_forwarding_rule" "apigee-xlb-http" {
  ip_address            = google_compute_global_address.apigee-xlb.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  name                  = "api-${var.env}-${google_apigee_organization.org.name}-http2https-redirect"
  port_range            = "80-80"
  target                = google_compute_target_http_proxy.apigee-xlb-http.self_link
}
resource "google_compute_target_http_proxy" "apigee-xlb-http" {
  name    = "api-${var.env}-${google_apigee_organization.org.name}-http2https-redirect"
  url_map = google_compute_url_map.apigee-xlb-http2https.self_link
}

resource "google_compute_url_map" "apigee-xlb-http2https" {
  default_url_redirect {
    https_redirect         = "true"
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = "false"
  }

  description = "Automatically generated HTTP to HTTPS redirect for the api-${var.env}-${google_apigee_organization.org.name}-http2https-redirect forwarding rule"
  name        = "api-${var.env}-${google_apigee_organization.org.name}-http2https"

}
