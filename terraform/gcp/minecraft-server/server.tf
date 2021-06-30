resource "google_compute_address" "minecraft-server-ip" {
  name         = "minecraft-server-${var.minecraft_server_name}-ip"
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
  name                   = "minecraft-${var.minecraft_server_name}-fr"
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
  name                            = "minecraft-${var.minecraft_server_name}-backend"
  port_name                       = "http"
  protocol                        = "TCP"
  region                          = var.region
  session_affinity                = "CLIENT_IP_PORT_PROTO"
  timeout_sec                     = "30"
}

resource "google_compute_region_health_check" "minecraft-lb-health" {
  check_interval_sec = "10"
  healthy_threshold  = "2"

  log_config {
    enable = "false"
  }

  name = "minecraft-lb-${var.minecraft_server_name}-health"

  region = var.region

  tcp_health_check {
    port         = "25565"
    proxy_header = "NONE"
  }

  timeout_sec         = "5"
  unhealthy_threshold = "3"
}


resource "google_compute_instance_template" "minecraft_template" {
  name_prefix  = "minecraft-server-${var.minecraft_server_name}-"
  machine_type = "e2-medium"
  region       = var.region

  // boot disk
  disk {
    source_image = data.google_compute_image.ubuntu-latest.self_link
  }

  metadata_startup_script = templatefile("init-server.tpl.sh", {
    GS_BUCKET = google_storage_bucket.minecraft-data.name
  })

  metadata = {
    enable-oslogin = "TRUE"
  }

  can_ip_forward = false

  network_interface {
    subnetwork = data.google_compute_subnetwork.private1.name
  }

  service_account {
    email  = google_service_account.minecraft-server.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "minecraft_group_manager" {
  name = "minecraft-server-${var.minecraft_server_name}"

  version {
    instance_template = google_compute_instance_template.minecraft_template.id
  }
  base_instance_name = "minecraft-server-${var.minecraft_server_name}"

  zone        = local.zone
  target_size = "1"

  named_port {
    name = "minecraft"
    port = 25565
  }

  named_port {
    name = "minecraft-rcon"
    port = 25575
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.minecraft-health-check.id
    initial_delay_sec = 300
  }
}

data "google_compute_image" "ubuntu-latest" {
  family  = "ubuntu-minimal-2104"
  project = "ubuntu-os-cloud"
}

resource "google_compute_health_check" "minecraft-health-check" {
  name = "tcp-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "25565"
  }
}


// Dedicated service account for the Bastion instance
resource "google_service_account" "minecraft-server" {
  account_id   = "minecraft-server-sa"
  display_name = "Service account for Minecraft server instance"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "minecraft-server-oslogin-user" {
  role   = "roles/compute.osLogin"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}

# allows to gsutil cp both directions
resource "google_project_iam_member" "minecraft-server-gs" {
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}


resource "google_compute_address" "minecraft-server" {
  name         = "minecraft-server"
  address_type = "EXTERNAL"
}


output "minecraft_server_external_ip" {
  value = google_compute_address.minecraft-server.address
}

# let connect via to minecraft server only within GCP VPC or via IAP tunnel
resource "google_compute_firewall" "minecraft-server-ssh" {
  name          = "minecraft-server-ssh"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["10.0.0.0/8", "35.235.240.0/20"]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_service_accounts = [google_service_account.minecraft-server.email]
}

# let connect via to minecraft servers own TCP port only within GCP VPC or from Network Load Balancer ranges
# ...and from anyone - as External TCP Network LoadBalancer does pass throu TLS connection - hence internal GCP firewall are in charge for connections from real Minecraft clients
# it could be simplified - but leave as it is for clarity why
resource "google_compute_firewall" "minecraft-server-minecraft-ports" {
  name          = "minecraft-server"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["10.0.0.0/8", "130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["25565", "25575"]
  }

  target_service_accounts = [google_service_account.minecraft-server.email]
}
