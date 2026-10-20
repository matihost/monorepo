terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    instana = {
      # Official IBM Instana provider, available in both registries (OpenTofu: https://search.opentofu.org/provider/instana/instana/latest,
      # Terraform: https://registry.terraform.io/providers/instana/instana/latest/docs)
      # Since 6.0 it uses the Plugin Framework: nested settings are attributes (permission_set = {...}), not blocks
      source  = "instana/instana"
      version = "~> 7"
    }
  }
  required_version = ">= 1.6"
}
