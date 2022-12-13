provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}

# Normally Kubernetes and Helm could be init via
# But when K8S TF is used when TF is created it leads to error upon second run
# https://itnext.io/terraform-dont-use-kubernetes-provider-with-your-cluster-resource-d8ec5319d14a
#
# data "google_container_cluster" "my_cluster" {
#   name     = local.gke_name
#   location = local.location
# }
# provider "kubernetes" {
#   load_config_file = false

#   host  = "https://${data.google_container_cluster.gke.endpoint}"
#   token = data.google_client_config.current.access_token
#   cluster_ca_certificate = base64decode(
#     data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
#   )
# }

# provider "helm" {
#   kubernetes {
#     host  = "https://${data.google_container_cluster.gke.endpoint}"
#     token = data.google_client_config.current.access_token
#     cluster_ca_certificate = base64decode(
#       data.google_container_cluster.gke.master_auth[0].cluster_ca_certificate,
#     )
#   }
# }

provider "kubernetes" {
  config_paths = ["${path.module}/target/${local.gke_name}/kubeconfig"]
}

provider "helm" {
  kubernetes {
    config_paths = ["${path.module}/target/${local.gke_name}/kubeconfig"]
  }
}

module "gke_auth" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = ">= 24"

  project_id   = var.project
  cluster_name = local.gke_name
  location     = local.location
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${path.module}/target/${local.gke_name}/kubeconfig"
}


data "google_client_config" "current" {}
data "google_project" "current" {
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


variable "regional_cluster" {
  type        = bool
  default     = false
  description = "Whether to create regional cluster. Default false - which means cluster will be zonal."
}
