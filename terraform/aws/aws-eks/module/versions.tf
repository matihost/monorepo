terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
  }
  required_version = ">= 1.6"
}
