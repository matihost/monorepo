terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # TODO  change to >= 5.1 - but registry.opentofu.org has missing fresh google provider
      version = "= 5.0.0"
    }
  }
  required_version = ">= 1.6"
}
