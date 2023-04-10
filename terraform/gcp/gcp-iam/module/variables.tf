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
