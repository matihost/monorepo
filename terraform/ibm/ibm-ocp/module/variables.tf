locals {
  prefix            = "${var.env}-${var.region}-ocp"
  resource_group_id = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.resource.id
}


# tflint-ignore: terraform_unused_declarations
data "ibm_iam_account_settings" "account" {
}


data "ibm_resource_group" "resource" {
  name = var.resource_group_name != "" ? var.resource_group_name : var.env
}


variable "env" {
  type        = string
  description = "Environment name"
}

variable "resource_group_name" {
  type        = string
  description = "IBM Cloud Resource Group Name to place resources, if missing env will be used for resource group name"
  default     = "dev"
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources, if not provided it will be calculated from resource_group_name variable"
  default     = ""
}


variable "instance_profile" {
  type        = string
  description = "Instance profile for Worker nodes"
  default     = "bx2.4x16" // or cx2.8x16 or cx2.16x32
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "eu-de-1"
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
  type        = string
  description = "VPC Name to place instances"
}


variable "subnetworks" {
  type = map(object({
    name = string
  }))
  description = "IBM subnetworks (key is zone, value.name is subnet name)"
}
