terraform {
  required_providers {
    docker = {
      source  = "hashicorp/docker"
      version = ">= 2.7"
    }
  }
  required_version = ">= 1.6"
}
