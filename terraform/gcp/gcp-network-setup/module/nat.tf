resource "google_compute_router" "router" {
  count   = length(var.regions)
  name    = "router-${var.regions[count.index]}"
  region  = var.regions[count.index]
  network = google_compute_network.private.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  count                              = length(var.regions)
  name                               = "nat-${var.regions[count.index]}"
  router                             = google_compute_router.router[count.index].name
  region                             = google_compute_router.router[count.index].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
