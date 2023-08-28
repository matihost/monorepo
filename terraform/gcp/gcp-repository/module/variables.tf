variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone For Deployment"
}

# tflint-ignore: terraform_unused_declarations
variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
