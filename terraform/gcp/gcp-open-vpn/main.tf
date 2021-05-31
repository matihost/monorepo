provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

data "google_client_config" "current" {}
data "google_project" "current" {
}
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_network" "private" {
  name = "private-vpc"
}

data "google_compute_subnetwork" "private1" {
  name   = "private-subnet-${var.region}"
  region = var.region
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


variable "external_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "The public CIDR IP which is allowed to access VPN Gateway."
}


variable "onpremise_dns_zone_forward" {
  type = object({
    zone   = string
    dns_ip = string
  })
  default     = { "zone" : "", "dns_ip" : "" }
  description = "The public CIDR IP which is allowed to access VPN Gateway."
}
