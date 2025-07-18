terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    instana = {
      # TODO rebranded instana is not migrated to OpenTofu (yet?)
      # OpenTofu only contains: https://search.opentofu.org/provider/gessnerfl/instana/latest
      # While Terraform instana: https://registry.terraform.io/providers/instana/instana/latest/docs
      # Created ticket to OpenTofu Registry: https://github.com/opentofu/registry/issues/1412
      source  = "instana/instana"
      version = "~> 3"
      # version = "3.1.0"
      # source = "gessnerfl/instana"
      # version = "2.4.3"
    }
  }
  required_version = ">= 1.6"
}
