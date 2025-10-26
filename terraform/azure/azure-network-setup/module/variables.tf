data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "rg" {
  name = var.env
}

locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id     = data.azurerm_subscription.current.id
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.region
  prefix              = "${var.env}-${local.azure_region_abbreviations[var.region]}"
  subscription_name   = data.azurerm_subscription.current.display_name
  # tflint-ignore: terraform_unused_declarations
  key_vault_name = "${local.prefix}-${substr(sha256(local.subscription_name), 0, 7)}"
  azure_region_abbreviations = {
    "eastus"             = "eus"
    "eastus2"            = "eu2"
    "westus"             = "wus"
    "westus2"            = "wu2"
    "centralus"          = "cus"
    "northeurope"        = "neu"
    "westeurope"         = "weu"
    "southeastasia"      = "sea"
    "eastasia"           = "eas"
    "australiaeast"      = "aue"
    "australiasoutheast" = "aus"
    "japaneast"          = "jpe"
    "japanwest"          = "jpw"
    "canadacentral"      = "cac"
    "canadaeast"         = "cae"
    "germanywestcentral" = "gwc"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "polandcentral"      = "plc"
    "brazilsouth"        = "brs"
    "southafricanorth"   = "san"
    "southafricasouth"   = "sas"
    "francecentral"      = "frc"
    "francesouth"        = "frs"
    "uaecentral"         = "uae"
    "uaenorth"           = "uan"
    "koreacentral"       = "kor"
    "koreasouth"         = "kos"
    "switzerlandnorth"   = "chn"
    "switzerlandwest"    = "chw"
  }
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

variable "managed_bastion" {
  type = object({
    cidr_range = string
  })
  default     = null
  description = "Bastion Subnet and bastion resource related configuration"
}


variable "container_instance_id" {
  type        = string
  description = "Object Id of Azure Container Instance Service Principal. We have to grant this permission to create hybrid connections in the Azure Relay you specify. To get it: Get-AzADServicePrincipal -DisplayNameBeginsWith 'Azure Container Instance'"
}

variable "cloudshell" {
  type = object({
    cidr_range           = string
    storage_account_name = string
    shares               = list(string)
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
  default     = "westeurope-az1"
  type        = string
  description = "Preffered Azure AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "westeurope"
  type        = string
  description = "Preffered Azure region where resource need to be placed"
}


variable "env" {
  type        = string
  description = "Environment name, represents resource group"
}

variable "tags" {
  type        = map(string)
  description = "Azure tags"
  default     = {}
}
