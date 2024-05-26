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
# tflint-ignore: terraform_unused_declarations
data "google_compute_network" "default" {
  name = "default"
}

locals {
  zone     = "${var.region}-${var.zone_letter}"
  gke_name = "${var.cluster_name}-${var.env}"
  location = var.regional_cluster ? var.region : local.zone
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

variable "regional_cluster" {
  type        = bool
  default     = false
  description = "Whether to create regional cluster. Default false - which means cluster will be zonal."
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "cluster_name" {
  type        = string
  default     = "shared"
  description = "GKE Cluster Name Project For Deployment"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}
