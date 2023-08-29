locals {
  name          = "${var.env}-${var.name}"
  regional_name = "${var.env}-${var.name}-${var.region}"
}

# Own variables
variable "env" {
  type        = string
  description = "Name prefix fo objects, usually represent environment, examples: dev, int, cert, prod"
}


variable "instances" {
  type = set(object({
    region = string
    image  = string
  }))
  description = "Set of keycloak instances, each one has to be in a separate region"
}

variable "ha" {
  type        = bool
  default     = false
  description = "Is config HA or for development"
}

variable "name" {
  type        = string
  default     = "id"
  description = "Name of the service"
}

variable "url" {
  type        = string
  description = "Full URL under which site is visible"
}

variable "welcome_page" {
  type        = string
  description = "Redirect to this page instead of showing typical KeyCloak welcome page, usually a page to admin own user account in realm"
}

variable "tls_key" {
  type        = string
  description = "TLS Key for url site"
}

variable "tls_crt" {
  type        = string
  description = "TLS Crt for url site"
}

#  Default inherited variables
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone For Deployment"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
