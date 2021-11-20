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
  machine_type = "e2-micro"
  zone         = local.zones[0]

  boot_disk {
    initialize_params {
      # # OpsAgents support only LTS
      # https://cloud.google.com/monitoring/agent/ops-agent?hl=en_US#supported_operating_systems
      image = "ubuntu-os-cloud/ubuntu-minimal-2104"
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = <<EOT
    #!/usr/bin/env bash
    apt-get update -y
    apt-get install -y bash-completion vim less bind9-dnsutils iputils-ping ncat
    snap install kubectl --classic
    # install OpsAgent (it reserves 8888 and 2020 ports)
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    bash add-google-cloud-ops-agent-repo.sh --also-install

    # install TinyProxy on 8787 port
    apt-get install -y tinyproxy
    sed -i 's/^Port .*$/Port 8787/g' /etc/tinyproxy/tinyproxy.conf
    systemctl restart tinyproxy
    EOT
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

  depends_on = [
    # to ensure that DNS resolver will get IP ending with .2
    google_dns_policy.allow-inbound-query-forwarding
  ]
}


// Dedicated service account for the Bastion instance
resource "google_service_account" "bastion" {
  account_id   = "${google_compute_network.private.name}-bastion-sa"
  display_name = "Service account for bastion instance"
}

# allows connect and operate as cluster-admin on any GKE cluster
# gcloud container clusters  get-credentials <gke-name> --[region|zone]=<location> --internal-ip
# kubectl get po -A
resource "google_project_iam_member" "bastion-gke-admin" {
  project = var.project

  role   = "roles/container.admin"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

# allows to gcloud SSH to VM (but they need to be running with same SA)
resource "google_project_iam_member" "bastion-oslogin-user" {
  project = var.project

  role   = "roles/compute.osLogin"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

# allows gcloud ssh to other VMs running with different GSA from bastion VM
# gcloud compute <vm-name> --zone=<zone> --internal-ip
resource "google_project_iam_member" "bastion-service-account-user" {
  project = var.project

  role   = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

# allows gcloud source repos list
resource "google_project_iam_member" "bastion-source-reader" {
  project = var.project

  role   = "roles/source.reader"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

# to let OpsAgent send logs
resource "google_project_iam_member" "bastion-log-writer" {
  project = var.project

  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.bastion.email}"
}

# to let OpsAgent expose metrics
resource "google_project_iam_member" "bastion-metrics-writer" {
  project = var.project

  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.bastion.email}"
}


output "bastion_instance_name" {
  value = google_compute_instance.bastion.name
}

output "bastion_instance_zone" {
  value = google_compute_instance.bastion.zone
}

output "bastion_instance_ssh_cmd" {
  value = format("gcloud compute ssh %s --zone=%s", google_compute_instance.bastion.name, google_compute_instance.bastion.zone)
}



output "bastion_tunnel_to_proxy" {
  value = format("gcloud compute ssh %s --zone=%s -- -o ExitOnForwardFailure=yes -M -S /tmp/sslsock -L8787:127.0.0.1:8787 -f sleep 36000", google_compute_instance.bastion.name, google_compute_instance.bastion.zone)
}
