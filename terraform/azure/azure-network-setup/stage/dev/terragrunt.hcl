include {
  path = find_in_parent_folders()
}

locals {
  storage_account = "${substr(run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh")), 0, 19)}shell"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev"
  vnet_ip_cidr_range = "10.0.0.0/16"
  cloudshell = {
    cidr_range           = "10.0.0.0/24"
    storage_account_name = local.storage_account
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
