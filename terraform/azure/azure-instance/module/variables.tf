data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "rg" {
  name = var.env
}

data "azurerm_key_vault" "key_vault" {
  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
}


locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id     = data.azurerm_subscription.current.id
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.region

  prefix            = "${var.env}-${local.azure_region_abbreviations[var.region]}"
  subscription_name = data.azurerm_subscription.current.display_name
  key_vault_name    = "${local.prefix}-${substr(sha256(local.subscription_name), 0, 7)}"
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


variable "name" {
  type        = string
  description = "VM name"
  default     = "vm"
}

variable "subnet_suffix" {
  type        = string
  description = "Suffix of the name of the subnet"
  default     = "vms"
}

variable "size" {
  type        = string
  description = "VM size"
  default     = "Standard_B2ats_v2" # 2 vcpu, 1 GiB memory
  # Standard_B1ls (1 vcpu, 0.5 GiB memory)
  # Standard_B1s (1 vcpu, 1 GiB memory)
}

variable "spot" {
  type        = bool
  description = "Whether to use spot instead of regular instances"
  default     = true
}


variable "image" {
  type = object({
    admin_username = string
    publisher      = string
    offer          = string
    sku            = string
    version        = string
  })
  default = {
    admin_username = "ubuntu"
    publisher      = "canonical"
    offer          = "ubuntu-24_04-lts"
    sku            = "minimal"
    version        = "latest"
  }
  description = "VM Image properties"
}


variable "ssh_pub_key" {
  type        = string
  description = "The pem encoded SSH pub key for accessing VMs"
  sensitive   = true
}

variable "ssh_key" {
  type        = string
  description = "The pem encoded SSH priv key to place on bastion"
  sensitive   = true
}


variable "user_data_template" {
  type        = string
  description = "EC2 user_data conttent in tftpl format (aka with TF templating)"
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
