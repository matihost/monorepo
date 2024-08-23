data "azurerm_subscription" "current" {
}

locals {
  # tflint-ignore: terraform_unused_declarations
  subscription_id = data.azurerm_subscription.current.id
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
