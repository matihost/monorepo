terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # Cluster uses config options available at:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/website/docs/r/container_cluster.html.markdown
      # in version:
      version = "~> 5"
      # Full Changelog for all version is here:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3"
    }
  }
  required_version = ">= 1.6"
}
