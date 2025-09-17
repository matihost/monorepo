terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 1.6"
}
