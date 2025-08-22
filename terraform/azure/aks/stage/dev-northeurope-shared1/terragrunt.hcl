include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env    = "dev"
  region = "northeurope"
  zone   = "northeurope-az1"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env          = local.env
  cluster_name = "shared1"
  region       = local.region
  zone         = local.zone

  system_subnet_suffix = "vms"
  worker_subnet_suffix = "vms"

  ha     = false
  public = true


  namespaces = [
    {
      name = "learning"
      quota = {
        limits = {
          cpu    = "12"
          memory = "16Gi"
        }
        requests = {
          cpu    = "12"
          memory = "16Gi"
        }
      }
    },
    {
      name = "test"
      quota = {
        limits = {
          cpu    = "8"
          memory = "16Gi"
        }
        requests = {
          cpu    = "8"
          memory = "16Gi"
        }
      }
  }]
}
