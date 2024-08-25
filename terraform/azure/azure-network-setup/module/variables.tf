data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "rg" {
  name = var.env
}

locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id         = data.azurerm_subscription.current.id
  resource_group_name     = data.azurerm_resource_group.rg.name
  resource_group_location = data.azurerm_resource_group.rg.location
  prefix                  = var.env
}


variable "vnet_ip_cidr_range" {
  default     = "10.0.0.0/16"
  type        = string
  description = "Virtual Network ip range"
}

variable "subnets" {
  type = map(object({
    cidr_range = string
  }))
  description = "Subnets"
}



# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "polandcentral-az1"
  type        = string
  description = "Preffered Azure AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "polandcentral"
  type        = string
  description = "Preffered Azure region where resource need to be placed"
}


variable "env" {
  type        = string
  description = "Environment name, represents resource group"
}
