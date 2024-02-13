variable "env" {
  type        = string
  description = "Environment name"
  default = "dev"
}

variable "resource_group_name" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources"
  default = "dev"
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources, if not provided it will be calculated from env variable"
  default = ""
}


variable "instance_profile" {
  type        = string
  description = "Instance profile for EC2 deployments"
  default = "cx2-2x4"
}

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
  default     = "dev-eu-de"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "subnetworks" {
  type = map(object({
      name = string
  }))
  description = "AWS subnetworks (key is zone, value.name is subnet name)"
  default = {
    "eu-de-1" = {
      name = "dev-eu-de-1-subnet"
    },
    "eu-de-2" = {
      name = "dev-eu-de-2-subnet"
    },
    "eu-de-3" = {
      name = "dev-eu-de-3-subnet"
    },
  }
}


variable "ssh_key_id" {
  default     = "dev-eu-de-bastion-ssh"
  type        = string
  description = "The name of key allowed to login to the instance, usually the bastion key id"
}

variable "private_security_group_name" {
  type        = string
  description = "The name of security group name assigned on EC2 webserver instances and private LBs"
  default = "dev-eu-de-internal-only"
}

variable "public_lb_security_group_name" {
  type        = string
  description = "The name of security group name assigned on public LBs"
  default = "dev-eu-de-bastion"
}

# tflint-ignore: terraform_unused_declarations
variable "iam_trusted_profile" {
  type        = string
  description = "The name of IAM trusted profile to attach to instance"
  default = "dev-eu-de-bastion"
}
