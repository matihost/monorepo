variable "env" {
  type        = string
  description = "Environment name"
}

variable "resource_group_name" {
  type        = string
  description = "IBM Cloud Resource Group Name to place resources, if missing env will be used for resource group name"
  default = "dev"
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud Resource Group ID to place resources, if not provided it will be calculated from resource_group_name variable"
  default = ""
}

variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
}

variable "create_sample_instance" {
  type        = bool
  default     = false
  description = "Whether to span single example instance in private subnet"
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
  default = {
    "eu-de-1" = {
      ip_cidr_range = "10.0.32.0/19"
    },
    "eu-de-2" = {
      ip_cidr_range = "10.0.64.0/19"
    },
    "eu-de-3" = {
      ip_cidr_range = "10.0.96.0/19"
    },
  }

}
