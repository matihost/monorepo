include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env              = "dev"
  locations        = ["West Europe", "Poland Central"]
  vm_sizes         = ["Standard_B1s", "Standard_B2ats_v2"]
  enforce_policies = false
}
