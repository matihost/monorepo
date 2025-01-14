locals {
  pub_ssh    = file("~/.ssh/id_rsa.aws.vm.pub")
  ssh_key    = file("~/.ssh/id_rsa.aws.vm")
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev-arm"
  region             = "us-east-1"
  zones              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc                = "dev-us-east-1" # or default to choose default VPC
  master_subnet      = "public"
  agent_subnet       = "private"
  ssh_pub_key        = local.pub_ssh
  ssh_key            = local.ssh_key
  external_access_ip = local.current_ip
  ec2_instance_type  = "t4g.small"
  ec2_architecture   = "arm64"
  aws_tags = {
    Env    = "dev-arm"
    Region = "us-east-1"
  }
}
