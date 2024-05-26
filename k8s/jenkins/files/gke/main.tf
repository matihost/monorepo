provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

# tflint-ignore: terraform_unused_declarations
data "google_client_config" "current" {}
# tflint-ignore: terraform_unused_declarations
data "google_project" "current" {
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

variable "gke_namespace" {
  type        = string
  description = "GKE Namespace where Jenkins is deployed"
  default     = "ci"
}
