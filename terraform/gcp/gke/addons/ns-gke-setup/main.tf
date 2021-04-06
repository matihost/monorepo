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

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  project_id   = var.project
  cluster_name = local.gke_name
  location     = local.location
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${path.module}/.terraform/kubeconfig"
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
  default     = "shared1"
  description = "GKE Cluster Name Project For Deployment"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}
