terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  # Only OpenTofu is supported as Terraform does not support
  required_version = ">= 1.9"
}
