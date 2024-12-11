data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = try(data.aws_caller_identity.current.arn, "")
}


locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${var.name != "" ? "${var.name}-" : ""}${var.env}-${var.region}"
}


variable "name" {
  type        = string
  description = "Name of the cluster"
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


variable "cluster_version" {
  type        = string
  default     = "1.31"
  description = "Version of EKS"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+$", var.cluster_version))
    error_message = "openshift_version must be with structure <major>.<minor> (for example 1.31)."
  }
}

variable "service_cidr" {
  type        = string
  default     = "172.30.0.0/16"
  description = "Block of IP addresses for services, for example \"172.30.0.0/16\"."
}


variable "cluster_admin_arn" {
  type        = string
  default     = null
  description = "The break glass cluster-admin arn, if none provided, the arn of the creator is chosen"
}
