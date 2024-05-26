terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }
  }
  required_version = ">= 1.5"
}
