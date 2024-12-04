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
  prefix              = "${var.env}-${var.region}"
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
