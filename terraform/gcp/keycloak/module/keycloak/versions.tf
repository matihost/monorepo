terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.80"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.80"
    }
  }
  required_version = ">= 1.2"
}
