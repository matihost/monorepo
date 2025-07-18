terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 1.0"
}
