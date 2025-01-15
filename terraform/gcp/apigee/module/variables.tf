data "google_client_config" "current" {}
data "google_project" "current" {
}

# tflint-ignore: terraform_unused_declarations
data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_network" "private" {
  name = "${var.env}-vpc"
}

data "google_compute_subnetwork" "private1" {
  name   = "${var.env}-${var.region}-subnet"
  region = var.region
}

data "google_dns_managed_zone" "main-zone" {
  name = var.env
}

locals {
  external_dns_name = replace(var.external_dns, ".", "-")
}


variable "apigee_envs" {
  type        = list(string)
  description = "Apigee Environments"
}


variable "external_dns" {
  type        = string
  description = "External DNS Apigee is exposed, sample api.dev.some.com"
}

variable "internal_cn_prefix" {
  type        = string
  default     = "api"
  description = "Internal DNS main zone prefix"
}

variable "tls_key" {
  type        = string
  description = "TLS Key for external dns site"
}

variable "tls_crt" {
  type        = string
  description = "TLS Crt for external dns site"
}

# Default inherited variables
variable "env" {
  type        = string
  description = "Environment, also VPC name"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

variable "region" {
  type        = string
  description = "GCP Region For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  type        = string
  description = "GCP Zone For Deployment"
}
