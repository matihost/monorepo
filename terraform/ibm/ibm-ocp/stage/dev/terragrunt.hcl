locals {
  # Ensure Resource Group name is in sync with Env name
  # Free Tier can use only Default One
  resource_group_id = "${run_cmd("--terragrunt-quiet", "sh", "-c", "ibmcloud resource group dev --output json | jq -r .[0].id")}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env               = "dev"
  resource_group_id = local.resource_group_id
  region            = "eu-de"
  zone              = "eu-de-1"
  vpc_name          = "dev-eu-de"
  instance_profile  = "bx2.4x16"

  subnetworks = {
    "eu-de-1" = {
      name = "dev-eu-de-1-subnet"
    },
    "eu-de-2" = {
      name = "dev-eu-de-2-subnet"
    },
    "eu-de-3" = {
      name = "dev-eu-de-3-subnet"
    },
  },
}
