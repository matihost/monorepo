locals {
  # tflint-ignore: terraform_unused_declarations
  name = "${var.env}-${var.name}"

  # tflint-ignore: terraform_unused_declarations
  regional_name = "${var.env}-${var.name}-${var.region}"
}

variable "keycloak_users" {
  type = list(object({
    email   = string
    name    = string
    surname = string
  }))

  description = "Keycloak users to configure"
  default     = []
}

# tflint-ignore: terraform_unused_declarations
variable "env" {
  type        = string
  description = "Name prefix fo objects, usually represent environment, examples: dev, int, cert, prod"
}

variable "realm_name" {
  type        = string
  description = "Name or the realm"
}

# tflint-ignore: terraform_unused_declarations
variable "name" {
  type        = string
  default     = "id"
  description = "Name of the service"
}

# tflint-ignore: terraform_unused_declarations
variable "url" {
  type        = string
  description = "Full URL under which site is visible"
}

#  Default inherited variables
# tflint-ignore: terraform_unused_declarations
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

# tflint-ignore: terraform_unused_declarations
variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
