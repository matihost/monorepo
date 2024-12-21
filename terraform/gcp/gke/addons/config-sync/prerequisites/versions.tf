terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # Cluster uses config options available at:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/website/docs/r/container_cluster.html.markdown
      # in version:
      version = "~> 6"
      # Full Changelog for all version is here:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/CHANGELOG.md
    }
  }
  required_version = ">= 1.6"
}
