data "google_client_config" "current" {}
data "google_project" "current" {
}
data "google_compute_network" "default" {
  name = "default"

  depends_on = [
    google_project_service.vpc-apis
  ]
}

# TODO move to variable
locals {
  zones = formatlist("%s-a", var.regions)
}

variable "regions" {
  type        = list(string)
  default     = ["us-central1", "us-east1", "europe-central2"]
  description = "GCP Region For Deployment"
}


variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone For Deployment"
}


variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}
