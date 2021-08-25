resource "google_compute_instance" "vm" {
  name         = "vpn-gateway"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2104"
    }
  }

  metadata_startup_script = templatefile("init-server.tpl.sh", {
    GS_BUCKET = google_storage_bucket.vpn-data.name,
    COUNTRY   = "PL",
    STATE     = "XX",
    CITY      = "YYY",
    ORG       = "OpenVPN",
    CA_EMAIL  = "me@me.me",
    CN_SERVER = "Server",
    CN_CLIENT = "Client"
  })

  metadata = {
    enable-oslogin = "TRUE"
    ssh-keys       = "ubuntu:${file("~/.ssh/id_rsa.cloud.vm.pub")}"
  }

  can_ip_forward = true

  network_interface {
    subnetwork = data.google_compute_subnetwork.private1.name

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


// Dedicated service account for the Bastion instance
resource "google_service_account" "vpn" {
  account_id   = "${data.google_compute_network.private.name}-vpn-sa"
  display_name = "Service account for VPN Gateway instance"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "vpn-oslogin-user" {
  role   = "roles/compute.osLogin"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# allows to gsutil cp both directions
resource "google_project_iam_member" "vpn-gs" {
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vpn.email}"
}

# allows gcloud ssh to other VMs running with different GSA from VPN VM
# gcloud compute <vm-name> --zone=<zone> --internal-ip
resource "google_project_iam_member" "vpn-service-account-user" {
  role   = "roles/iam.serviceAccountUser"
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
}

# So that GCP VPC can access VPN clients
resource "google_compute_route" "openvpn" {
  dest_range        = "10.8.0.0/24"
  name              = "openvpn-route"
  network           = data.google_compute_network.private.name
  next_hop_instance = google_compute_instance.vm.id
}
