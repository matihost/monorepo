locals {
  pub_ssh = try(file("~/.ssh/id_rsa.aws.vm.pub"), get_env("SSH_PUB", ""))
  ssh_key = try(file("~/.ssh/id_rsa.aws.vm"), get_env("SSH_PRIV", ""))
}
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                   = "dev"
  name                  = "instana"
  region                = "us-east-1"
  zone                  = "us-east-1a"
  vpc_name              = "dev-us-east-1"
  ssh_pub_key           = local.pub_ssh
  ssh_key               = local.ssh_key
  ec2_instance_type     = "t4g.small" # or t3.micro
  ec2_architecture      = "arm64"     # or x86_64
  ec2_ami_name_query    = "ubuntu/images/hvm-ssd-*/ubuntu-noble-24.04-*-server-*"
  ec2_ami_account_alias = "amazon"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
