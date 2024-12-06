data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}


locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id   = data.azurerm_subscription.current.id
  tenant_id         = data.azurerm_client_config.current.tenant_id
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
    "switzerlandnorth"   = "chn"
    "switzerlandwest"    = "chw"
  }
}

variable "locations" {
  default     = ["West Europe"]
  type        = list(string)
  description = "Allowed locations to be used in resource group"
}

variable "vm_sizes" {
  default     = ["Standard_B1s", "Standard_B2ats_v2"]
  type        = list(string)
  description = "Allowed VM possible sizes to be used in resource group"
}


variable "enforce_policies" {
  default     = true
  type        = bool
  description = "Whether resource group policies needs to be enforced (or audited only if false)"
}


# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "westeurope-az1"
  type        = string
  description = "Preffered Azure AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "westeurope"
  type        = string
  description = "Preffered Azure region where resource need to be placed"
}


variable "env" {
  type        = string
  description = "Environment name"
}
