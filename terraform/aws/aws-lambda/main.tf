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

variable "lambda_version" {
  default     = "1.0.0"
  description = "Version of lambda code"
}

variable "lambda_function_name" {
  default     = "synthetic-ec2-tester"
  description = "Name of lambda function"
}

variable "enable_eventrule_lambda_trigger" {
  default     = true
  description = "If set to true, the lambda is triggered every minute via CloudWatch Event Rule"
  type        = bool
}
