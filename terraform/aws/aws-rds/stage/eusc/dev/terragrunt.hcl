include "root" {
  path = find_in_parent_folders("eusc.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env      = "dev"
  region   = "eusc-de-east-1"
  zone     = "eusc-de-east-1a"
  vpc_name = "dev-eusc-de-east-1"
  aws_tags = {
    Env    = "dev"
    Region = "eusc-de-east-1"
  }
  zones = [
    "eusc-de-east-1a", "eusc-de-east-1b",
    # TODO eusc does not have 3 AZs yet
    # "eusc-de-east-1c"
  ]
  dbs = {
    "dev" : {
      db_name = "app",
    },
  }
}
