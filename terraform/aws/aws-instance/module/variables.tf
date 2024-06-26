data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = var.env
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}


variable "name" {
  type        = string
  description = "EC2 name"
  default     = "vm"
}

variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
}

variable "vpc" {
  type        = string
  description = "VPC name where to place VM, when 'default' value, default VPC is used "
  default     = "default"
}

variable "subnet" {
  type        = string
  description = "Subnet name where to place VM, when 'default' value, default subnet for zone is used, otherwise Tier tag name is used"
  default     = "default"
}


variable "ec2_instance_type" {
  type        = string
  description = "Instance type for EC2 deployments"
  default     = "t3.micro"
}

variable "ec2_architecture" {
  type        = string
  description = "Instance type for EC2 deployments"
  default     = "x86_64"
}

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

# tflint-ignore: terraform_unused_declarations
variable "aws_tags" {
  type        = map(string)
  description = "AWS tags"
}

variable "instance_profile" {
  default     = ""
  type        = string
  description = "The name of instance_profile (dynamically provisioning access to role)"
}


variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}
