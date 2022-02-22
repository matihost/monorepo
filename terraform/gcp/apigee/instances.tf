locals {
  regions = toset([
    var.region
  ])
  envs = toset(var.envs)
}

data "google_kms_key_ring" "keyring" {
  for_each = local.regions
  name     = "${each.key}-keyring"
  location = each.key
}

data "google_kms_crypto_key" "disk-key" {
  for_each = local.regions
  name     = "apigee-${each.key}-disk-enc-key"
  key_ring = data.google_kms_key_ring.keyring[each.key].id
}

resource "google_kms_crypto_key_iam_binding" "apigee-disk-keyuser" {
  for_each      = local.regions
  crypto_key_id = data.google_kms_crypto_key.disk-key[each.key].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.apigee-sa.email}",
  ]
}

resource "google_apigee_instance" "instance" {
  for_each = local.regions

  name = "${var.env}-${google_apigee_organization.org.name}-${each.key}"

  # only single instance per region is possible
  location    = each.key
  description = "Apigee Runtime Instance in ${each.key}"
  org_id      = google_apigee_organization.org.id

  disk_encryption_key_name = data.google_kms_crypto_key.disk-key[each.key].id

  ip_range = "10.9.0.0/22"

  depends_on = [
    google_kms_crypto_key_iam_binding.apigee-disk-keyuser,
  ]
}

# TODO enable when Google provider releases apigee nat resource
# resource "google_apigee_nat_address" "instance-nat-1" {
#   instance_id  = google_apigee_instance.instance.id
#   name  = "${google_apigee_instance.google_apigee_instance.name}-nat-1"
# }

resource "google_apigee_environment" "env" {
  for_each = local.envs

  name         = each.key
  description  = "Apigee Environment: ${each.key}"
  display_name = each.key
  org_id       = google_apigee_organization.org.id
}

resource "google_apigee_instance_attachment" "intance-env-attachment" {
  for_each = local.envs

  instance_id = google_apigee_instance.instance[var.region].id
  environment = google_apigee_environment.env[each.key].name
}

resource "google_dns_record_set" "instance-dns" {
  name = "api.${data.google_dns_managed_zone.main-zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.main-zone.name

  rrdatas = [google_apigee_instance.instance[var.region].host]
}


resource "google_apigee_envgroup" "envgroup" {
  name      = var.env
  hostnames = [trimsuffix(google_dns_record_set.instance-dns.name, "."), var.external_dns]
  org_id    = google_apigee_organization.org.id
}

resource "google_apigee_envgroup_attachment" "envgroup-attachment" {
  for_each    = local.envs
  envgroup_id = google_apigee_envgroup.envgroup.id
  environment = google_apigee_environment.env[each.key].name
}
