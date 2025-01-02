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
  sensitive   = true
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
  sensitive   = true
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


variable "ec2_ami_name_query" {
  type        = string
  description = "EC2 AMI name query"
}


variable "ec2_ami_account" {
  default     = ""
  type        = string
  description = "EC2 AMI AWS account id"
}

variable "ec2_ami_account_alias" {
  default     = ""
  type        = string
  description = "EC2 AMI AWS account id"
}


variable "user_data_template" {
  type        = string
  description = "EC2 user_data content in tftpl format (aka with TF templating)"
}

variable "user_data_vars" {
  default     = []
  type        = list(string)
  description = "Variables passed as vars variable in cloud init templating"
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


variable "external_access_range" {
  default     = "0.0.0.0/0"
  type        = string
  description = "The public IP which is allowed to access instance"
}
