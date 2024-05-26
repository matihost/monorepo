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
data "google_compute_network" "private" {
  name = "private-vpc"
}

# tflint-ignore: terraform_unused_declarations
data "google_compute_subnetwork" "private" {
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

# tflint-ignore: terraform_unused_declarations
variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}

variable "gh_token" {
  type        = string
  description = "GitHub PAT for CloudBuild usage"
}

variable "gh_repo_owner" {
  type        = string
  default     = "matihost"
  description = "GitHub Owner/Organization"
}

variable "gh_repo_name" {
  type        = string
  default     = "monorepo"
  description = "Repository name"
}

variable "gh_cloud_build_app_id" {
  type        = number
  description = "GitHub Google Cloud Build Application ID"
}
