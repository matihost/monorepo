terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 1.6"
}
