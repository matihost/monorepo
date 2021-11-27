resource "google_compute_address" "minecraft-server-ip" {
  name         = "${var.minecraft_server_name}-minecraft-server-ip"
  address_type = "EXTERNAL"
}

# Uses GCP External TCP/UDP Network Load Balancing
# (after this referred to as Network Load Balancing)
# is a regional, pass-through load balancer.
# A network load balancer distributes
# external traffic among virtual machine (VM) instances in the same region.
resource "google_compute_forwarding_rule" "minecraft-fr" {
  region = var.region

  all_ports              = "false"
  allow_global_access    = "false"
  backend_service        = google_compute_region_backend_service.minecraft-region-backend.self_link
  ip_address             = google_compute_address.minecraft-server-ip.address
  ip_protocol            = "TCP"
  is_mirroring_collector = "false"
  load_balancing_scheme  = "EXTERNAL"
  name                   = "${var.minecraft_server_name}-minecraft-fr"
  network_tier           = "PREMIUM"
  ports                  = ["25565", "25575"]
}

resource "google_compute_region_backend_service" "minecraft-region-backend" {
  affinity_cookie_ttl_sec = "0"

  backend {
    balancing_mode  = "CONNECTION"
    capacity_scaler = "0"
    failover        = "false"
    group           = google_compute_instance_group_manager.minecraft_group_manager.instance_group
  }

  connection_draining_timeout_sec = "300"
  enable_cdn                      = "false"
  health_checks                   = [google_compute_region_health_check.minecraft-lb-health.id]
  load_balancing_scheme           = "EXTERNAL"
  name                            = "${var.minecraft_server_name}-minecraft-backend"
  port_name                       = "http"
  protocol                        = "TCP"
  region                          = var.region
  session_affinity                = "CLIENT_IP_PORT_PROTO"
  timeout_sec                     = "30"
}

# lb will detach instance after 200 seconds from Minecraft crash
resource "google_compute_region_health_check" "minecraft-lb-health" {
  check_interval_sec = "20"
  healthy_threshold  = "2"

  log_config {
    enable = "false"
  }

  name = "${var.minecraft_server_name}-minecraft-lb-health"

  region = var.region

  tcp_health_check {
    port         = "25565"
    proxy_header = "NONE"
  }

  timeout_sec         = "5"
  unhealthy_threshold = "10"
}


output "minecraft_server_external_ip" {
  value = google_compute_address.minecraft-server-ip.address
}
