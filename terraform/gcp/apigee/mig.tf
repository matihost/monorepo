# Regional resources
resource "google_compute_region_instance_group_manager" "apigee-mig-group-manager" {
  name = "mig-${var.env}-${google_apigee_organization.org.name}-${var.region}"

  version {
    instance_template = google_compute_instance_template.apigee-mig-template.id
  }
  base_instance_name = "mig-${var.env}-${google_apigee_organization.org.name}-${var.region}"

  region = var.region

  target_size = "1"

  named_port {
    name = "https"
    port = 443
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.apigee-mig-health-check.id
    initial_delay_sec = 120
  }
}


resource "google_compute_backend_service" "apigee-mig" {
  affinity_cookie_ttl_sec = "0"

  backend {
    balancing_mode               = "UTILIZATION"
    capacity_scaler              = "1"
    group                        = google_compute_region_instance_group_manager.apigee-mig-group-manager.instance_group
    max_connections              = "0"
    max_connections_per_endpoint = "0"
    max_connections_per_instance = "0"
    max_rate                     = "0"
    max_rate_per_endpoint        = "0"
    max_rate_per_instance        = "0"
    max_utilization              = "0.8"
  }

  connection_draining_timeout_sec = "300"
  enable_cdn                      = "false"
  health_checks                   = [google_compute_health_check.apigee-mig-health-check.self_link]
  load_balancing_scheme           = "EXTERNAL"

  log_config {
    enable = "false"
  }

  name             = "mig-${var.env}-${google_apigee_organization.org.name}-${var.region}"
  port_name        = "https"
  protocol         = "HTTPS"
  session_affinity = "NONE"
  timeout_sec      = "300"
}

# Global, common to all regions, resources

resource "google_compute_instance_template" "apigee-mig-template" {
  name_prefix  = "mig-${var.env}-${google_apigee_organization.org.name}"
  machine_type = "e2-medium"
  region       = var.region

  // boot disk
  disk {
    source_image = data.google_compute_image.ubuntu-latest.self_link
    disk_type    = "pd-standard"
    disk_size_gb = 10
  }

  metadata = {
    apigee_runtime_endpoint = google_apigee_instance.instance[var.region].host
    enable-oslogin          = "TRUE"
    startup-script          = file("${path.module}/mig-startup-script.sh")
  }

  can_ip_forward = true

  network_interface {
    subnetwork = data.google_compute_subnetwork.private1.name
  }

  service_account {
    email  = google_service_account.apigee.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "google_compute_image" "ubuntu-latest" {
  # OpsAgents support only LTS: https://cloud.google.com/monitoring/agent/ops-agent?hl=en_US#supported_operating_systems
  family  = "ubuntu-minimal-2110"
  project = "ubuntu-os-cloud"
}

resource "google_compute_health_check" "apigee-mig-health-check" {
  name = "mig-${var.env}-${google_apigee_organization.org.name}-autohealing-tcp-health-check"

  timeout_sec        = 5
  check_interval_sec = 5
  healthy_threshold  = "2"

  unhealthy_threshold = 5

  //TODO add https healthcheck
  // curl -vk -H 'User-Agent: GoogleHC/' https://api.dev.gcp.testing/healthz/exchanges

  tcp_health_check {
    port         = "443"
    proxy_header = "NONE"
  }
}


# let connect via to apigee-mig servers only within GCP VPC or via IAP tunnel
resource "google_compute_firewall" "apigee-mig-ssh" {
  name      = "mig-${var.env}-${google_apigee_organization.org.name}-ssh"
  network   = data.google_compute_network.private.name
  direction = "INGRESS"
  project   = var.project
  # 35.235.240.0/20 represents adresses used for IAP
  source_ranges = ["10.0.0.0/8", "35.235.240.0/20"]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_service_accounts = [google_service_account.apigee.email]
}

# allow connect to Apigee MIG servers from  within GCP VPC or from Load Balancer ranges
resource "google_compute_firewall" "apigee-mig-https" {
  name          = "mig-${var.env}-${google_apigee_organization.org.name}-https"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["10.0.0.0/8", "130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_service_accounts = [google_service_account.apigee.email]
}
