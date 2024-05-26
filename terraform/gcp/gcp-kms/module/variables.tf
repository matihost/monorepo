variable "regions" {
  type        = set(string)
  description = "Regions to place KMS keys"
}


variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  type        = string
  description = "GCP Region For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  type        = string
  description = "GCP Zone For Deployment"
}
