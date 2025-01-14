include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                             = "dev"
  lambda_function_name            = "synthetic-ec2-tester"
  enable_eventrule_lambda_trigger = true
  vm_name                         = "dev-us-east-1-vm"
  vpc                             = "dev-us-east-1" # or default to choose default VPC
  subnet                          = "public"
  region                          = "us-east-1"
  zone                            = "us-east-1a"

  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
}
