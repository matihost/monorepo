data "aws_caller_identity" "current" {}


locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${var.name != "" ? "${var.name}-" : ""}${var.env}-${var.region}"
}


variable "name" {
  type        = string
  description = "Name of the efs"
  default     = ""
}

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


variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}


variable "vpc_name" {
  default     = "dev-us-east-1"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "zones" {
  type        = set(string)
  description = "AWS zones for VPC Subnetworks Deployment"
}
