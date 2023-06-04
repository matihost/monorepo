variable "gh_repo_owner" {
  type        = string
  description = "GitHub Owner/Organization"
}

variable "gh_repo_name" {
  type        = string
  description = "Repository name"
}


# Mandatory variables for GCP Provider and GS storage for TF state setup
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP Region For Deployment"
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP Zone For Deployment"
}

variable "project" {
  type        = string
  description = "GCP Project For Deployment"
}
