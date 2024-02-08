locals {
  prefix = "${var.env}-${var.region}-ocp"
}


# tflint-ignore: terraform_unused_declarations
data "ibm_iam_account_settings" "account" {
}


# User var.resource_group_id as it has to be provided to ibm provider
# Here only to check whether resource_group is obtainable from env name
#
# tflint-ignore: terraform_unused_declarations
data "ibm_resource_group" "resource" {
  name = var.env
}


variable "env" {
  type        = string
  description = "Environment name"
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources"
}



variable "instance_profile" {
  type        = string
  description = "Instance profile for Worker nodes"
  default = "cx2.8x16"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered IBM Cloud AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "eu-de"
  type        = string
  description = "Preffered IBM Cloud region where resource need to be placed"
}



variable "vpc_name" {
  default     = "dev-us-east-1"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "subnetworks" {
  type = map(object({
      name = string
  }))
  description = "AWS subnetworks (key is zone, value.name is subnet name)"
}
