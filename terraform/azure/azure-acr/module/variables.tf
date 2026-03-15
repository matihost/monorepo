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
  # tflint-ignore: terraform_unused_declarations
  subscription_id     = data.azurerm_subscription.current.id
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.region

  prefix            = "${var.env}-${local.azure_region_abbreviations[var.region]}"
  subscription_name = data.azurerm_subscription.current.display_name
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
    "swedencentral"      = "swc"
    "swedensouth"        = "sws"
    "norwayeast"         = "noe"
    "norwaywest"         = "now"
    "switzerlandnorth"   = "swn"
    "switzerlandwest"    = "sww"
    "italynorth"         = "itn"
    "israelcentral"      = "isc"
    "qatarcentral"       = "qac"
    "spaincentral"       = "spc"
    "newzealandnorth"    = "nzn"
    "australiacentral"   = "auc"
    "australiacentral2"  = "au2"
    "mexicocentral"      = "mxc"
    "indiacentral"       = "inc"
    "indiaseast"         = "ise"
    "indiasouth"         = "iss"
    "indiasouth"         = "isw"
    "japanwest"          = "jpw"
    "chinanorth"         = "chn"
    "chinaeast"          = "che"
    "chinaeast2"         = "ch2"
    "chinanorth2"        = "ch3"
    "chinanorth3"        = "ch4"
    "germanycentral"     = "gmc"
    "germanynortheast"   = "gne"
    "usgovarizona"       = "uga"
    "usgovtexas"         = "ugt"
    "usgovvirginia"      = "ugv"
    "usgovpennsylvania"  = "ugp"
    "usdodeast"          = "ude"
    "usdodcentral"       = "udc"
    "usgovarizona"       = "uga"
    "usgovtexas"         = "ugt"
    "usgovvirginia"      = "ugv"
    "usgovpennsylvania"  = "ugp"
    "usdodeast"          = "ude"
    "usdodcentral"       = "udc"
  }
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "acr"
}


variable "admin_enabled" {
  description = "Enable admin user for the Azure Container Registry"
  type        = bool
  default     = false
}


variable "public" {
  description = "Expose ACR to public network, otherwise only private endpoint access possible"
  type        = bool
  default     = false
}

variable "private_endpoints_subnet_suffix" {
  type        = string
  description = "Name of subnet for private endpoints"
}


variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

output "rg" {
  value = local.resource_group_name
}
