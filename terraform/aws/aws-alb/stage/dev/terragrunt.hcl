locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
}

include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev"
  external_access_ip = local.current_ip
  instance_profile   = "SSM-EC2"
  ec2_instance_type  = "t4g.small" # or t3.micro
  ec2_architecture   = "arm64"     # or x86_64
  aws_tags           = { Env = "dev" }
}
