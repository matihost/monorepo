
data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = "${var.env}-webserver"
}

variable "env" {
  type        = string
  description = "Environment name"
}

# tflint-ignore: terraform_unused_declarations
variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}


variable "ec2_instance_type" {
  type        = string
  description = "Instance type for EC2 deployments"
  default = "t3.micro"
}

variable "ec2_architecture" {
  type        = string
  description = "Instance type for EC2 deployments"
  default = "x86_64"
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


variable "ec2_instance_profile" {
  default     = ""
  type        = string
  description = "The name of instance_profile (dynamically provisioning access to role)"
}


variable "zones" {
  type = set(string)
  description = "AWS zones for VPC Subnetworks Deployment"
}


variable "ec2_ssh_key_id" {
  default     = ""
  type        = string
  description = "The name of key allowed to login to the instance, usually the bastion key id"
}

# TODO create own?
variable "ec2_security_group_name" {
  type        = string
  description = "The name of security group name assigned on EC2 webserver instances"
}

variable "public_lb_security_group_name" {
  type        = string
  description = "The name of security group name assigned on Public LB"
}
