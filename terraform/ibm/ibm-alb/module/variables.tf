locals {
  prefix = "${var.env}-webserver"
  resource_group_id = var.resource_group_id != "" ? var.resource_group_id : data.ibm_resource_group.resource.id
}

# User var.resource_group_id as it has to be provided to ibm provider
# Here only to check whether resource_group is obtainable from env name
#
# tflint-ignore: terraform_unused_declarations
data "ibm_resource_group" "resource" {
  name = var.resource_group_name != "" ? var.resource_group_name : var.env
}


variable "env" {
  type        = string
  description = "Environment name"
}

variable "resource_group_name" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources"
  default = ""
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources"
  default = ""
}


variable "instance_profile" {
  type        = string
  description = "Instance profile for EC2 deployments"
  default = "cx2-2x4"
}

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


variable "ssh_key_id" {
  default     = ""
  type        = string
  description = "The name of key allowed to login to the instance, usually the bastion key id"
}

variable "private_security_group_name" {
  type        = string
  description = "The name of security group name assigned on EC2 webserver instances and private LBs"
}

variable "public_lb_security_group_name" {
  type        = string
  description = "The name of security group name assigned on public LBs"
}

# tflint-ignore: terraform_unused_declarations
variable "iam_trusted_profile" {
  type        = string
  description = "The name of IAM trusted profile to attach to instance"
}
