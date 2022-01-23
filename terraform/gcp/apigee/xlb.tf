resource "google_compute_global_address" "apigee-xlb" {
  name         = "apigee-${var.env}-${google_apigee_organization.org.name}"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}
