terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2"
    }
  }
  required_version = ">= 1.6"
}
