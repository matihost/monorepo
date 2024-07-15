data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = var.env
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
}

variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}


variable "create_sample_instance" {
  type        = bool
  default     = false
  description = "Whether to span single instance in private subnet"
}

variable "create_ssm_private_access_vpc_endpoints" {
  type        = bool
  default     = true
  description = "Whether to create VPC endpoints reguired to be able to connect to EC2 instances w/o public IP via System Manager"
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

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}


variable "vpc_ip_cidr_range" {
  type        = string
  description = "Regional VPC range"
}

variable "zones" {
  type = map(object({
    public_ip_cidr_range  = string
    private_ip_cidr_range = string
  }))
  description = "AWS zones for VPC Subnetworks Deployment"
}
