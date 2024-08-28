data "azurerm_subscription" "current" {
}

locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id = data.azurerm_subscription.current.id
}


variable "locations" {
  default     = ["Poland Central"]
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
  default     = "polandcentral-az1"
  type        = string
  description = "Preffered Azure AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "polandcentral"
  type        = string
  description = "Preffered Azure region where resource need to be placed"
}


variable "env" {
  type        = string
  description = "Environment name"
}
