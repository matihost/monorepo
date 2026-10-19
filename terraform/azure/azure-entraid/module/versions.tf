terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3"
    }
    random = {
      source = "hashicorp/random"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0"
    }
  }
  required_version = ">= 1.0"
}
