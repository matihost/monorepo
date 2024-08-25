include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev"
  vnet_ip_cidr_range = "10.0.0.0/16"
  subnets = {
    "a" = {
      cidr_range = "10.0.32.0/19"
    },
    "b" = {
      cidr_range = "10.0.64.0/19"
    },
    "c" = {
      cidr_range = "10.0.96.0/19"
    }
  }
}
