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



variable "container_instance_id" {
  type        = string
  description = "Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance'"
}

variable "cloudshell" {
  type = object({
    cidr_range           = string
    storage_account_name = string
  })
  description = "CloudShell Subnet and Related Resource Configuration"
}


variable "relay" {
  type = object({
    cidr_range = string
  })
  description = "Relay Subnet and Related Resource Configuration"
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
