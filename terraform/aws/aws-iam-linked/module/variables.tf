data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "org" {}

locals {
  account_id                = data.aws_caller_identity.current.account_id
  org_management_account_id = data.aws_organizations_organization.org.master_account_id
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
