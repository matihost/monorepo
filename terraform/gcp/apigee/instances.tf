
resource "google_apigee_instance" "instance" {
  name = "${var.env}-${google_apigee_organization.org.name}-${var.region}"

  # only single instance per region is possible
  location    = var.region
  description = "Apigee Runtime Instance in ${var.region}"
  org_id      = google_apigee_organization.org.id

  # disk encyption only for paid subscription only
  # disk_encryption_key_name = google_kms_crypto_key.apigee-key.id
  # evaluation/trial subscription are only SLASH_22 or SLASH_23
  peering_cidr_range = "SLASH_22"
}

# TODO enable when Google provider 4.6.0 is released
# resource "google_apigee_nat_address" "instance-nat-1" {
#   instance_id  = google_apigee_instance.instance.id
#   name  = "${google_apigee_instance.google_apigee_instance.name}-nat-1"
# }

resource "google_apigee_environment" "env" {
  name         = var.env
  description  = "Apigee Environment: ${var.env}"
  display_name = var.env
  org_id       = google_apigee_organization.org.id
}

resource "google_apigee_instance_attachment" "intance-env-attachment" {
  instance_id = google_apigee_instance.instance.id
  environment = google_apigee_environment.env.name
}

resource "google_dns_record_set" "instance-dns" {
  name = "api.${data.google_dns_managed_zone.main-zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.main-zone.name

  rrdatas = [google_apigee_instance.instance.host]
}


resource "google_apigee_envgroup" "envgroup" {
  name      = var.env
  hostnames = [trimsuffix(google_dns_record_set.instance-dns.name, "."), var.external_dns]
  org_id    = google_apigee_organization.org.id
}

resource "google_apigee_envgroup_attachment" "envgroup-attachment" {
  envgroup_id = google_apigee_envgroup.envgroup.id
  environment = google_apigee_environment.env.name
}
