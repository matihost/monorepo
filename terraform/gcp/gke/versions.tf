terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # Cluster uses config options available at:
      # https://github.com/hashicorp/terraform-provider-google/blob/master/website/docs/r/container_cluster.html.markdown
      # in version:
      version = ">= 3.69"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.69"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.15"
}
