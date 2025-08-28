include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env              = "dev"
  locations        = ["West Europe", "Poland Central", "North Europe"]
  locations_short  = ["westeurope", "polandcentral", "northeurope"]
  vm_sizes         = ["Standard_B1s", "Standard_B2ats_v2", "Standard_D8s_v5", "Standard_D4s_v5"]
  enforce_policies = false
}
