# set enable-oslogin metadata on project level to add this metadata to each VM created within GCP project
resource "google_compute_project_metadata_item" "os-login" {
  key   = "enable-oslogin"
  value = "TRUE"
}

resource "google_compute_network" "vpc" {
  name                     = "${var.env}-vpc"
  auto_create_subnetworks  = "false"
  enable_ula_internal_ipv6 = "true"

  depends_on = [
    google_project_service.apis
  ]
}

# For private GKE cluster
# Primary ip_cidr_range has to belong to rfc1918 and it is used for GKE nodes
# Secondary adress ranges can be non-rfc1918, but it complicates NAT:
# https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_reserved_ip_ranges
resource "google_compute_subnetwork" "subnet" {
  for_each      = var.regions
  name          = "${var.env}-${each.key}-subnet"
  region        = each.key
  network       = google_compute_network.vpc.name
  ip_cidr_range = each.value.ip_cidr_range

  private_ip_google_access = true
  # TODO field not used yet
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "INTERNAL"

  dynamic "secondary_ip_range" {
    for_each = { for range in each.value.secondary_ranges : range.range_name => range }
    iterator = ip_range
    content {
      range_name    = ip_range.key
      ip_cidr_range = ip_range.value.ip_cidr_range
    }
  }
}


# Subnetwork for HTTP internal load balancer proxies
# https://cloud.google.com/load-balancing/docs/proxy-only-subnets#proxy_only_subnet_create
resource "google_compute_subnetwork" "l7lb-subnet" {
  for_each = var.regions

  name          = "${var.env}-${each.key}-l7lb-subnet"
  ip_cidr_range = each.value.l7lb_proxy_cidr_range
  region        = each.key
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc.name

  project = var.project
}
