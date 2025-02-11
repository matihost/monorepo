data "azuread_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "rg" {
  name = var.env
}

data "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-vnet"
  resource_group_name = local.resource_group_name
}


locals {
  cluster_name = "${local.prefix}-${var.cluster_name}"
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


variable "cluster_name" {
  type        = string
  description = "Name of cluster"
}

variable "master_subnet_suffix" {
  type        = string
  description = "Name of subnet for master nodes"
}

variable "worker_subnet_suffix" {
  type        = string
  description = "Name of subnet for worker nodes"
}

variable "rh_pull_secret" {
  type        = string
  description = "RH Pull Secret obtained from https://console.redhat.com/openshift/install/azure/aro-provisioned"
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
