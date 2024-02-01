locals {
  prefix = var.env
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


variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
}

# tflint-ignore: terraform_unused_declarations
variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}

# tflint-ignore: terraform_unused_declarations
variable "create_sample_instance" {
  type        = bool
  default     = false
  description = "Whether to span single instance in private subnet"
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


variable "zones" {
  type = map(object({
      ip_cidr_range = string
  }))
  description = "IBM Cloud zones for VPC Subnetworks Deployment"
}
