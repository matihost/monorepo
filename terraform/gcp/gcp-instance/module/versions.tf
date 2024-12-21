terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 1.6"
}
