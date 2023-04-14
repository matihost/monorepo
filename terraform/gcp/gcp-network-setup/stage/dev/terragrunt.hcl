include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

inputs = {
    env = "dev"
    # TODO move config of ip ranges to regions variable
    regions = ["us-central1", "us-east1", "europe-central2"]
}
