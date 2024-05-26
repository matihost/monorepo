terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 1.6"
}
