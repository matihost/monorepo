provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

data "google_client_openid_userinfo" "me" {
}


resource "google_os_login_ssh_public_key" "login" {
  user    = data.google_client_openid_userinfo.me.email
  key     = file("~/.ssh/id_rsa.cloud.vm.pub")
  project = var.project
}



locals {
  zone = "${var.region}-${var.zone_letter}"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

variable "zone_letter" {
  type        = string
  default     = "a"
  description = "GCP Region For Deployment"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
