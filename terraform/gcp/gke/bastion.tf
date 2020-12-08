// Allow access to the Bastion Host via SSH
resource "google_compute_firewall" "bastion-ssh" {
  name          = "${local.gke_name}-bastion-ssh"
  network       = google_compute_network.private-gke.name
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
  name         = "${local.gke_name}-bastion"
  machine_type = "f1-micro"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2010"
    }
  }

  metadata_startup_script = <<EOT
  #!/usr/bin/env bash
  sudo apt-get update -y
  sudo apt-get install -y vim bind9-dnsutils tinyproxy
  sudo snap install kubectl --classic
  EOT

  metadata = {
    enable-oslogin = "TRUE"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private-gke.name

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


output "bastion_instance_name" {
  value = google_compute_instance.bastion.name
}


output "bastion_tunnel_to_proxy" {
  value = format("gcloud compute ssh %s -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8888:127.0.0.1:8888 -f sleep 36000", google_compute_instance.bastion.name)
}
