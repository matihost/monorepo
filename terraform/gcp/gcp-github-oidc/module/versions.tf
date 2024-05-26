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
  }
  required_version = ">= 1.5"
}
