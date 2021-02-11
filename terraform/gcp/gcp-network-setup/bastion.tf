// Allow access to the Bastion Host via SSH
resource "google_compute_firewall" "bastion-ssh" {
  name          = "${google_compute_network.private.name}-bastion-ssh"
  network       = google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_service_accounts = [google_service_account.bastion.email]
}

// A single Compute Engine instance
resource "google_compute_instance" "bastion" {
  name         = "${google_compute_network.private.name}-bastion"
  machine_type = "f1-micro"
  zone         = local.zones[0]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2010"
    }
  }

  metadata_startup_script = <<EOT
  #!/usr/bin/env bash
  sudo apt-get update -y
  sudo apt-get install -y bash-completion vim bind9-dnsutils tinyproxy
  sudo snap install kubectl --classic
  EOT

  metadata = {
    enable-oslogin = "TRUE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private1.name

    # Do not add public IP, connect only via gcloud compute ssh --tunnel-through-iap
    # access_config {
    #   // Include this section to give the VM an external ip address
    # }
  }

  // Allow the instance to be stopped by terraform when updating configuration
  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }
}


// Dedicated service account for the Bastion instance
resource "google_service_account" "bastion" {
  account_id   = "${google_compute_network.private.name}-bastion-sa"
  display_name = "Service account for bastion instance"
}

# allows connect and operate as cluster-admin on any GKE cluster
# gcloud container clusters  get-credentials <gke-name> --[region|zone]=<location> --internal-ip
# kubectl get po -A
resource "google_project_iam_binding" "bastion-gke-admin" {
  role = "roles/container.admin"

  members = [
    "serviceAccount:${google_service_account.bastion.email}",
  ]
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_binding" "bastion-oslogin-user" {
  role = "roles/compute.osLogin"

  members = [
    "serviceAccount:${google_service_account.bastion.email}",
  ]
}

# allows gcloud ssh to other VMs running with different GSA from bastion VM
# gcloud compute <vm-name> --zone=<zone> --internal-ip
resource "google_project_iam_binding" "bastion-service-account-user" {
  role = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.bastion.email}",
  ]
}


output "bastion_instance_name" {
  value = google_compute_instance.bastion.name
}


output "bastion_tunnel_to_proxy" {
  value = format("gcloud compute ssh %s -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8888:127.0.0.1:8888 -f sleep 36000", google_compute_instance.bastion.name)
}
