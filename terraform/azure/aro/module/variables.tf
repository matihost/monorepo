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


variable "namespaces" {
  type = list(object({
    name = string
    quota = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })
  }))

  description = "EKS namespaces configuration"
  default = [{
    name = "test"
    quota = {
      limits = {
        cpu    = "12"
        memory = "16Gi"
      }
      requests = {
        cpu    = "12"
        memory = "16Gi"
      }
    }
  }]
}


variable "oidc" {
  type = object({
    oidc_name      = string
    issuer_url     = string
    client_id      = string
    client_secret  = string
    username_claim = optional(string, "preferred_username")
    groups_claim   = optional(string, "groups")
  })

  default = null

  description = "ARO OIDC provider configuration"

  # Sample Keycloak config:
  #
  # default = {
  #   issuer = "https://id.matihost.mooo.com/realms/id"
  #   client_id = "aro"
  #   username_claim = "email"
  #   groups_claim = "groups"
  # }
  #
  # Sample token:
  #
  # {
  # "exp": 1734443783,
  # "iat": 1734443483,
  # "auth_time": 1734442743,
  # "jti": "936ace3f-181c-40ca-8bc6-7c7d7093ead8",
  # "iss": "https://id.matihost.mooo.com/realms/id",
  # "aud": "eks",
  # "sub": "f76a1839-abdd-4e1c-9869-b73fa8ed64e8",
  # "typ": "ID",
  # "azp": "eks",
  # "nonce": "ccBdcKskRQZC3LJVfpU-R7pC2mQ03Oz2FQwMxO4C-XY",
  # "sid": "ceb826f0-eed3-4666-8d76-9a95610fa15c",
  # "at_hash": "Djmh28ZTxRYW_bnhO4TIlA",
  # "acr": "0",
  # "email_verified": true,
  # "name": "Name Surname",
  # "groups": [
  #   "/cluster-admins"
  # ],
  # "preferred_username": "name@email.com",
  # "given_name": "Name",
  # "family_name": "Surname",
  # "email": "name@email.com"
  # }
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
