
data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  # tflint-ignore: terraform_unused_declarations
  prefix = "${var.name}-${var.env}-${var.region}"

  dns_prefix = replace(var.dns, ".", "-")
}

variable "name" {
  type        = string
  description = "Name of the objects"
}


variable "dns" {
  type        = string
  description = "DNS of the site"
}


variable "enable_tls" {
  type        = bool
  description = "DNS of the site"
  default     = false
}

variable "tls_crt" {
  type        = string
  description = "TLS certificate"
  default     = ""
  sensitive   = true
}

variable "tls_chain" {
  type        = string
  description = "TLS chain"
  default     = ""
  sensitive   = true
}

variable "tls_key" {
  type        = string
  description = "TLS key"
  default     = ""
  sensitive   = true
}


# Default variables

variable "env" {
  type        = string
  description = "Environment name"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}

# tflint-ignore: terraform_unused_declarations
variable "aws_tags" {
  type        = map(string)
  description = "AWS tags"
}
