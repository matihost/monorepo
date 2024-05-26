locals {
  name = "${var.env}-${var.name}"
  # tflint-ignore: terraform_unused_declarations
  regional_name = "${var.env}-${var.name}-${var.region}"
}

# Own variables
variable "env" {
  type        = string
  description = "Name prefix fo objects, usually represent environment, examples: dev, int, cert, prod"
}

variable "name" {
  type        = string
  default     = "droneshuttles"
  description = "Name of the service"
}

variable "ghost_admin_key" {
  type        = string
  description = <<-EOT
    Ghost Admin Key from Custom Integration of the Ghost instance
    To create one :
    Go to http://<url>/ghost and create initial admin account
    Login to that and account and go to: http://<url>/ghost/#/settings/integrations/new/
    Name it like "Cloud Function Integration"
    You will see a page with Admin and Content key tokens.
    Use Admin key here.
  EOT
}

variable "ghost_content_key" {
  type        = string
  description = <<-EOT
    Ghost Content Key from Custom Integration of the Ghost instance
    To create one :
    Go to http://<url>/ghost and create initial admin account
    Login to that and account and go to: http://<url>/ghost/#/settings/integrations/new/
    Name it like "Cloud Function Integration"
    You will see a page with Admin and Content key tokens.
    Use Content key here.
  EOT
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
