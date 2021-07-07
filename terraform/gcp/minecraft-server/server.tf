resource "google_compute_instance_template" "minecraft_template" {
  name_prefix  = "minecraft-server-${var.minecraft_server_name}-"
  machine_type = "e2-medium"
  region       = var.region

  // boot disk
  disk {
    source_image = data.google_compute_image.ubuntu-latest.self_link
  }

  metadata_startup_script = templatefile("init-server.tpl.sh", {
    GS_BUCKET             = google_storage_bucket.minecraft-data.name,
    MINECRAFT_SERVER_NAME = var.minecraft_server_name
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


// Dedicated service account for the Minecraft server instance
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
