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

data "google_container_cluster" "gke" {
  name     = local.gke_name
  location = local.location
}

locals {
  zone         = "${var.region}-${var.zone_letter}"
  gke_name     = var.cluster_name
  location     = var.regional_cluster ? var.region : local.zone
  gke_nodes_sa = data.google_container_cluster.gke.node_config[0].service_account
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

variable "cluster_name" {
  type        = string
  description = "GKE Cluster Name Project For Deployment"
}

variable "enable_internal_ingress_node_pool" {
  type        = bool
  default     = false
  description = "Whether to create separated node pool for internal"
}

variable "enable_external_ingress_node_pool" {
  type        = bool
  default     = false
  description = "Whether to create separated node pool for internal"
}

variable "regional_cluster" {
  type        = bool
  default     = false
  description = "Whether to create regional cluster. Default false - which means cluster will be zonal."
}
