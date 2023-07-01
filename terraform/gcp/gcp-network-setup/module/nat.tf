resource "google_compute_router" "router" {
  for_each = var.regions

  name    = "${var.env}-${each.key}-router"
  region  = each.key
  network = google_compute_network.vpc.id

  bgp {
    asn = var.asn
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = var.regions
  name     = "${var.env}-${each.key}-nat"

  router                             = google_compute_router.router[each.key].name
  region                             = google_compute_router.router[each.key].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
