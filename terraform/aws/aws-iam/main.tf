provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

variable "zone" {
  default     = "us-east-1a"
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "us-east-1"
  description = "Preffered AWS region where resource need to be placed"
}
