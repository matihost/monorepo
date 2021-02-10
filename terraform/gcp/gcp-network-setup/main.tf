provider "google" {
  region  = var.regions[0]
  zone    = local.zones[0]
  project = var.project
}

data "google_client_config" "current" {}
data "google_project" "current" {
}
data "google_compute_network" "default" {
  name = "default"
}

locals {
  zones = formatlist("%s-${var.zone_letter}", var.regions)
}

variable "regions" {
  type        = list(string)
  default     = ["us-central1", "us-east1"]
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
