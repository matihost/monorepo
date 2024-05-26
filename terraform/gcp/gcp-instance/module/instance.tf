// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "vm" {
  name         = "${var.name}-${random_id.instance_id.hex}"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = templatefile("instance.init.sh.tpl", {
      ssh_key = filebase64("~/.ssh/id_rsa.cloud.vm"),
      ssh_pub = filebase64("~/.ssh/id_rsa.cloud.vm.pub"),
    })
    # startup-script-url = "gs://bucket/context/path/some-startup-script.sh"
  }

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  // to enable default-allow-http firewall rule.
  tags = ["http-server"]

  # If not given, the default Google Compute Engine service account is used.
  # service_account {
  #    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  #   email  = google_service_account.default.email
  #   scopes = ["cloud-platform"]
  # }
}

resource "google_compute_health_check" "http-health-check" {
  name = "http-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port = 80
  }
}

output "public_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}


output "instance_name" {
  value = google_compute_instance.vm.name
}


# Own variables

variable "name" {
  type        = string
  description = "Name prefix for VM"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

variable "zone" {
  type        = string
  default     = "us-central1-aaaaaa"
  description = "GCP Zone For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
