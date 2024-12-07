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
  description = "Set of Ghost instances, each one has to be in a separate region"
}

variable "ha" {
  type        = bool
  default     = false
  description = "Is config HA or for development"
}

variable "name" {
  type        = string
  default     = "ghost"
  description = "Name of the service"
}

variable "url" {
  type        = string
  description = "Full URL under which site is visible, for example: http://ghost.mooo.com"
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
