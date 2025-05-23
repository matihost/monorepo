data "google_compute_network" "vpc" {
  name = var.vpc
}

data "google_compute_subnetwork" "subnet" {
  name   = var.vpc_subnet
  region = var.region
}

resource "google_compute_instance_template" "minecraft_template" {
  name_prefix  = "${var.minecraft_server_name}-minecraft-server-"
  machine_type = var.machine_type
  region       = var.region

  // boot disk
  disk {
    source_image = data.google_compute_image.ubuntu-latest.self_link
  }

  # spot instance
  scheduling {
    automatic_restart           = false
    provisioning_model          = "SPOT"
    preemptible                 = true
    instance_termination_action = "STOP"
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = templatefile("${path.module}/init-server.tpl.sh", {
      GS_BUCKET             = google_storage_bucket.minecraft-data.name,
      MINECRAFT_SERVER_NAME = var.minecraft_server_name
    })
    shutdown-script = file("${path.module}/shutdown-server.sh")
  }

  can_ip_forward = false

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.name
  }

  service_account {
    email  = google_service_account.minecraft-server.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_storage_bucket_object.minecraft-config-template-object
  ]
}

resource "google_compute_instance_group_manager" "minecraft_group_manager" {
  name = "${var.minecraft_server_name}-minecraft-server"

  version {
    instance_template = google_compute_instance_template.minecraft_template.id
  }
  base_instance_name = "${var.minecraft_server_name}-minecraft-server"

  zone        = var.zone
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

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 0
    max_unavailable_fixed = 1
    replacement_method    = "RECREATE"
  }

  lifecycle {
    ignore_changes = [
      target_size
    ]
  }
}

data "google_compute_image" "ubuntu-latest" {
  # OpsAgents supported OS: https://cloud.google.com/monitoring/agent/ops-agent?hl=en_US#supported_operating_systems
  family  = "ubuntu-minimal-2404-lts-amd64"
  project = "ubuntu-os-cloud"
}

resource "google_compute_health_check" "minecraft-health-check" {
  name = "${var.minecraft_server_name}-autohealing-tcp-health-check"

  timeout_sec        = 5
  check_interval_sec = 20
  healthy_threshold  = "2"

  unhealthy_threshold = 10

  tcp_health_check {
    port         = "25565"
    proxy_header = "NONE"
  }
}


// Dedicated service account for the Minecraft server instance
resource "google_service_account" "minecraft-server" {
  account_id   = "${var.minecraft_server_name}-minecraft-server-sa"
  display_name = "Service account for Minecraft ${var.minecraft_server_name} server instance"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "minecraft-server-oslogin-user" {
  project = var.project

  role   = "roles/compute.osAdminLogin"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}

# allows to gsutil cp both directions
resource "google_project_iam_member" "minecraft-server-gs" {
  project = var.project

  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}

# to let OpsAgent send logs
resource "google_project_iam_member" "minecraft-server-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}

# to let OpsAgent expose metrics
resource "google_project_iam_member" "minecraft-server-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.minecraft-server.email}"
}

# let connect via to minecraft server only within GCP VPC or via IAP tunnel
resource "google_compute_firewall" "minecraft-server-ssh" {
  name          = "${var.minecraft_server_name}-minecraft-server-ssh"
  network       = data.google_compute_network.vpc.name
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
  name          = "${var.minecraft_server_name}-minecraft-server"
  network       = data.google_compute_network.vpc.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["10.0.0.0/8", "130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["25565", "25575"]
  }

  target_service_accounts = [google_service_account.minecraft-server.email]
}
