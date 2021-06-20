
resource "google_compute_instance" "vm" {
  name         = "minecraft-server"
  machine_type = "e2-standard-2"
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2104"
    }
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

    access_config {
      // to ensure externall address will not change
      nat_ip = google_compute_address.minecraft-server.address
    }
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.minecraft-server.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
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

resource "google_compute_firewall" "minecraft-server-ssh" {
  name          = "minecraft-server-ssh"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = flatten(concat(["10.0.0.0/8"], var.external_access_cidrs))

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_service_accounts = [google_service_account.minecraft-server.email]
}

resource "google_compute_firewall" "minecraft-server-minecraft-ports" {
  name          = "minecraft-server"
  network       = data.google_compute_network.private.name
  direction     = "INGRESS"
  project       = var.project
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["25565", "25575"]
  }

  target_service_accounts = [google_service_account.minecraft-server.email]
}
