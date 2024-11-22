terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1"

    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
  }
  required_version = ">= 1.6"
}
