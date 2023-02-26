provider "google" {
  region  = var.region
  zone    = local.zone
  project = var.project
}


data "google_client_config" "current" {}
data "google_project" "current" {
}

data "google_compute_network" "private" {
  name = "private-vpc"
}

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

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}
