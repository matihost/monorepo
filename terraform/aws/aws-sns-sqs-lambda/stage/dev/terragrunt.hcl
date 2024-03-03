include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env    = "dev"
  region = "us-east-1"
  zone   = "us-east-1a"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
}
