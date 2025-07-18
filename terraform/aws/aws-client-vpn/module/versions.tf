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
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
  # Only OpenTofu is supported as Terraform does not support
  required_version = ">= 1.10"
}
