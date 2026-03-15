include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env    = "dev"
  region = "westeurope"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

inputs = {
  env                             = local.env
  region                          = local.region
  name                            = "shared1"
  admin_enabled                   = true
  private_endpoints_subnet_suffix = "pe"
  tags = {
    environment = local.env
    region      = local.region
  }
}
