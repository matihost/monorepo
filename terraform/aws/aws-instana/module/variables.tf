data "aws_caller_identity" "current" {}


locals {
  # tflint-ignore: terraform_unused_declarations
  account_id     = data.aws_caller_identity.current.account_id
  instana_org    = split("-", var.instana_endpoint)[0]
  instana_tenant = split(".", split("-", var.instana_endpoint)[1])[0]
  prefix         = "${var.env}-${var.region}-${var.name != "" ? "${var.name}-" : ""}${local.instana_org}-${local.instana_tenant}"
}

data "aws_vpc" "vpc" {
  default = var.vpc_name == "default" ? true : null

  tags = var.vpc_name == "default" ? null : {
    Name = var.vpc_name
  }
}

data "aws_subnet" "private" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = each.key
  tags = {
    Tier = "private"
  }
}

# tflint-ignore: terraform_unused_declarations
variable "instana_token" {
  type        = string
  description = "Instana token for API interaction (Instana UI changes)"
  sensitive   = true
}

variable "instana_endpoint" {
  type        = string
  description = "Instana endpoint in form <tenant>-<org>.instana.io for Instana UI changes"
  sensitive   = true
}

variable "instana_agent_token" {
  type        = string
  description = "Instana token for Instana Agent access to Instana Agent backend"
  sensitive   = true
}

variable "instana_agent_backend" {
  type        = string
  description = "Instana backend in form: ingress-green-saas.instana.io:443 for Agent backend"
  default     = "ingress-green-saas.instana.io:443"
}


variable "instana_admin_email" {
  type        = string
  description = "Email of the person for main email notification channel"
}

variable "name" {
  type        = string
  description = "Name of the instana app"
  default     = ""
}

variable "env" {
  type        = string
  description = "Environment name"
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
