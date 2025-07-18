terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 1.0"
}
