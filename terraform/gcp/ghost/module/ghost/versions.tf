terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # Cluster uses config options available at:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/website/docs/r/container_cluster.html.markdown
      # in version:

      # TODO  change to >= 5.1 - but registry.opentofu.org has missing fresh google provider
      version = "= 5.0.0"
      # Full Changelog for all version is here:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      # TODO  change to >= 5.1 - but registry.opentofu.org has missing fresh google provider
      version = "= 5.0.0"
    }
  }
  required_version = ">= 1.6"
}
