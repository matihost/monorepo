include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

# some inputs duplication due to https://github.com/gruntwork-io/terragrunt/issues/1566
inputs = {
  env = "dev"
}
