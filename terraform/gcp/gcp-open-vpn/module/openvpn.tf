resource "google_compute_instance" "vm" {
  name         = local.prefix
  machine_type = "e2-micro"
  zone         = var.zone

  scheduling {
    # provisioning_model = "SPOT"
    # preemptible        = true
    automatic_restart = false
  }

  boot_disk {
    initialize_params {
      # OpsAgents support only LTS:
      # https://cloud.google.com/monitoring/agent/ops-agent?hl=en_US#supported_operating_systems
      image = "ubuntu-os-cloud/ubuntu-minimal-2404-lts-amd64"
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys       = "ubuntu:${var.ssh_pub_key}"
    server-conf    = file("${path.module}/server.conf")
    startup-script = templatefile("${path.module}/init-server.tpl.sh", {
      PREFIX = local.prefix
    })
  }

  can_ip_forward = true

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.name

    access_config {
      // to ensure externall address will not change
      nat_ip = google_compute_address.external-vpn.address
    }
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.vpn.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}


// Dedicated service account for the VPN instance
resource "google_service_account" "vpn" {
  account_id   = "${data.google_compute_network.private.name}-vpn-sa"
  display_name = "Service account for VPN Gateway instance"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "vpn-oslogin-user" {
  project = var.project

  role   = "roles/compute.osLogin"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# allows to gsutil cp both directions
resource "google_project_iam_member" "vpn-gs" {
  project = var.project

  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# allows gcloud ssh to other VMs running with different GSA from VPN VM
# gcloud compute <vm-name> --zone=<zone> --internal-ip
resource "google_project_iam_member" "vpn-service-account-user" {
  project = var.project

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# to let OpsAgent send logs
resource "google_project_iam_member" "vpn-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# to let OpsAgent expose metrics
resource "google_project_iam_member" "vpn-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# to read OpenVPN secrets
resource "google_project_iam_member" "vpn-secrets-accessor" {
  project = var.project

  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.vpn.email}"
}


resource "google_compute_address" "external-vpn" {
  name         = "${data.google_compute_network.private.name}-vpn-gateway"
  address_type = "EXTERNAL"
}


output "vpn_gateway_external_ip" {
  value = google_compute_address.external-vpn.address
}

# Cloud VPN acts as a router - it allows 22, DNS queries from both networks (home & GCP) and from GCP CloudDNS special range
resource "google_compute_firewall" "vpn" {
  name          = "${data.google_compute_network.private.name}-vpn"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = flatten(concat(["10.0.0.0/8", "35.199.192.0/19"], var.external_access_cidrs))

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "53"]
  }
  allow {
    protocol = "udp"
    ports    = ["1194", "53"] # CloudDNS uses UDP port still for DNS queries
  }

  target_service_accounts = [google_service_account.vpn.email]

  depends_on = [
    google_secret_manager_secret_version.ca-crt-data,
    google_secret_manager_secret_version.ca-key-data,
    google_secret_manager_secret_version.client-crt-data,
    google_secret_manager_secret_version.client-key-data,
    google_secret_manager_secret_version.server-crt-data,
    google_secret_manager_secret_version.server-key-data,
    google_secret_manager_secret_version.ta-key-data,
    google_secret_manager_secret_version.dh-data,
  ]
}

# So that GCP VPC can access VPN clients
resource "google_compute_route" "openvpn" {
  dest_range        = "10.8.0.0/24"
  name              = "openvpn-route"
  network           = data.google_compute_network.private.name
  next_hop_instance = google_compute_instance.vm.id
}


output "client-ovpn-all" {
  description = "client.ovpn file with routing entire client network traffic via VPN server"
  sensitive   = true
  value = templatefile("${path.module}/client.ovpn.tpl", {
    vpn_ip                = google_compute_address.external-vpn.address
    vpn_additional_config = "redirect-gateway def1 bypass-dhcp"
    ca_crt                = var.ca_crt
    ca_key                = var.ca_key
    client_crt            = var.client_crt
    client_key            = var.client_key
    ta_key                = var.ta_key
  })
}


output "client-ovpn-vpc" {
  description = "client.ovpn file with routing only GCP VPC to the client, the client internet traffic is not routed via VPN server"
  sensitive   = true
  value = templatefile("${path.module}/client.ovpn.tpl", {
    vpn_ip                = google_compute_address.external-vpn.address
    vpn_additional_config = ""
    ca_crt                = var.ca_crt
    ca_key                = var.ca_key
    client_crt            = var.client_crt
    client_key            = var.client_key
    ta_key                = var.ta_key
  })
}

output "vpn-vm-name" {
  value = google_compute_instance.vm.name
}

output "vpn-vm-zone" {
  value = google_compute_instance.vm.zone
}
