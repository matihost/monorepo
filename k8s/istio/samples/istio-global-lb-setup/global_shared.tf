# resource "google_compute_ssl_certificate" "default" {
#   name_prefix = "my-certificate-"
#   private_key = file("path/to/private.key")
#   certificate = file("path/to/certificate.crt")

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "google_compute_managed_ssl_certificate" "cert_id" {
  certificate_id = "3626195738218164562"
  name           = "http-external-gke-shared1-dev"
  type           = "MANAGED"
}

resource "google_compute_health_check" "istio" {
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
