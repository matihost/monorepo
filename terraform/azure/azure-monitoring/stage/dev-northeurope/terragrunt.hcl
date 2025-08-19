include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env             = "dev"
  region          = "northeurope"
  region_abbr     = "neu"
  zone            = "northeurope-az1"
  storage_account = "cshell2${local.env}2${local.region_abbr}2${substr(uuidv5("dns", run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))), 0, 6)}"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env    = "dev"
  region = local.region
  zone   = local.zone
}
