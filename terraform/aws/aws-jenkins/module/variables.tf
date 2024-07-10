data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = "${var.env}-${var.region}-${var.name}"

  master_subnet_ids = [for subnet in data.aws_subnet.master_subnet : subnet.id]
  agent_subnet_ids  = [for subnet in data.aws_subnet.agent_subnet : subnet.id]
}


data "aws_vpc" "default" {
  default = var.vpc == "default" ? true : null

  tags = var.vpc == "default" ? null : {
    Name = var.vpc
  }
}



data "aws_subnet" "master_subnet" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  default_for_az    = var.master_subnet == "default" ? true : null

  tags = var.master_subnet == "default" ? null : {
    Tier = var.master_subnet
  }
}


data "aws_subnet" "agent_subnet" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  default_for_az    = var.agent_subnet == "default" ? true : null

  tags = var.agent_subnet == "default" ? null : {
    Tier = var.agent_subnet
  }
}


variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}


variable "name" {
  type        = string
  description = "Jenkins name"
  default     = "jenkins"
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

variable "master_subnet" {
  type        = string
  description = "Subnet name where to place VM of Jenkins Master, when 'default' value, default subnet for zone is used, otherwise Tier tag name is used"
  default     = "default"
}

variable "agent_subnet" {
  type        = string
  description = "Subnet name where to place VMs of Jenkins Agents, when 'default' value, default subnet for zone is used, otherwise Tier tag name is used"
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

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}

variable "zones" {
  type        = set(string)
  description = "AWS zones for VPC Subnetworks Deployment"
}

variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}
