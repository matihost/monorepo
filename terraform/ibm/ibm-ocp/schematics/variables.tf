variable "env" {
  type        = string
  description = "Environment name"
  default = "dev"
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

variable "instance_profile" {
  type        = string
  description = "Instance profile for Worker nodes"
  default = "bx2.4x16" // or cx2.8x16 or cx2.1x32
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



variable "vpc_name" {
  default     = "dev-eu-de"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "subnetworks" {
  type = map(object({
      name = string
  }))
  description = "IBM subnetworks (key is zone, value.name is subnet name)"
  default = {
    "eu-de-1" = {
      name = "dev-eu-de-1-subnet"
    },
    "eu-de-2" = {
      name = "dev-eu-de-2-subnet"
    },
    "eu-de-3" = {
      name = "dev-eu-de-3-subnet"
    }
  }
}
