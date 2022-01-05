
resource "google_apigee_instance" "instance" {
  name = "${var.env}-${google_apigee_organization.org.name}-${local.zone}"

  # location has to be zone for trial subscription, or region for paid subscription
  location    = local.zone
  description = "Apigee Runtime Instance in ${local.zone}"
  org_id      = google_apigee_organization.org.id

  # disk encyption only for paid subscription only
  # disk_encryption_key_name = google_kms_crypto_key.apigee-key.id
  peering_cidr_range = "SLASH_22"
}

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
  hostnames = [google_dns_record_set.instance-dns.name]
  org_id    = google_apigee_organization.org.id
}

resource "google_apigee_envgroup_attachment" "envgroup-attachment" {
  envgroup_id = google_apigee_envgroup.envgroup.id
  environment = google_apigee_environment.env.name
}
