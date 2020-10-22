provider "aws" {
  region = var.region
}

variable "zone" {
  default     = "us-east-1a"
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

variable "region" {
  default     = "us-east-1"
  description = "Preffered AWS region where resource need to be placed"
}
