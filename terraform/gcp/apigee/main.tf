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

data "google_dns_managed_zone" "main-zone" {
  name = var.env
}

locals {
  zone                      = "${var.region}-${var.zone_letter}"
  external_dns_name         = replace(var.external_dns, ".", "-")
  external_tls_key_filename = var.external_tls_key != "" ? var.external_tls_key : "target/${var.external_dns}.key"
  external_tls_crt_filename = var.external_tls_crt != "" ? var.external_tls_crt : "target/${var.external_dns}.crt"
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
  description = "Environment, also default environment"
}


variable "external_dns" {
  type        = string
  description = "External DNS Apigee is exposed, sample api.dev.some.com"
}

variable "external_tls_key" {
  type        = string
  default     = ""
  description = "External DNS Apigee TLS Key file path"
}

variable "external_tls_crt" {
  type        = string
  default     = ""
  description = "External DNS Apigee TLS Crt file path"
}
