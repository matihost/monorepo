
data "aws_caller_identity" "current" {}

locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id

  prefix = "${var.env}-${var.region}"
}

variable "env" {
  type        = string
  description = "Environment name"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}

# tflint-ignore: terraform_unused_declarations
variable "aws_tags" {
  type = map(string)
  description = "AWS tags"
}

variable "vpc" {
  type        = string
  description = "VPC name where to place VM, when 'default' value, default VPC is used "
  default     = "default"
}

variable "subnet" {
  type        = string
  description = "Subnet name where to place VM, when 'default' value, default subnet for zone is used, otherwise Tier tag name is used"
  default     = "default"
}


variable "lambda_function_name" {
  type        = string
  default     = "synthetic-ec2-tester"
  description = "Name of lambda function"
}

variable "enable_eventrule_lambda_trigger" {
  default     = true
  description = "If set to true, the lambda is triggered every minute via CloudWatch Event Rule"
  type        = bool
}


variable "vm_name" {
  type        = string
  description = "EC2 name"
  default     = "dev-us-east-1-vm"
}
