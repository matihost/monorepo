include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env             = "dev"
  storage_account = "cshell2${local.env}2we2${substr(uuidv5("dns", run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))), 0, 6)}"
  region          = "westeurope"
  zone            = "westeurope-az1"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev"
  region             = local.region
  zone               = local.zone
  vnet_ip_cidr_range = "10.0.0.0/16"
  bastion = {
    cidr_range = "10.0.3.0/27"
  }
  cloudshell = {
    cidr_range           = "10.0.0.0/24"
    storage_account_name = local.storage_account
    shares               = ["shared-cloudshell-storage"]
  }
  relay = {
    cidr_range = "10.0.1.0/24"
  }
  storage = {
    cidr_range = "10.0.2.0/24"
  }
  subnets = {
    "vms" = {
      cidr_range = "10.0.32.0/19"
    },
    "containers" = {
      cidr_range = "10.0.64.0/19"
    }
  }
}
