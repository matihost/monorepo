locals {
  current_ip         = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
  pub_ssh            = try(file("~/.ssh/id_rsa.aws.vm.pub"), get_env("SSH_PUB", ""))
  ssh_key            = try(file("~/.ssh/id_rsa.aws.vm"), get_env("SSH_PRIV", ""))
  user_data_template = file("ec2.cloud-init.tpl")
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
  name                  = "ubuntu"
  vpc                   = "dev-us-east-1" # or default to choose default VPC
  subnet                = "private"
  region                = "us-east-1"
  zone                  = "us-east-1a"
  ssh_pub_key           = local.pub_ssh
  ssh_key               = local.ssh_key
  external_access_range = "${local.current_ip}/32"
  instance_profile      = ""
  ec2_instance_type     = "t4g.small" # or t3.micro
  ec2_architecture      = "arm64"     # or x86_64
  ec2_ami_name_query    = "ubuntu/images/hvm-ssd-*/ubuntu-noble-24.04-*-server-*"
  ec2_ami_account_alias = "amazon"
  user_data_template    = local.user_data_template
  user_data_vars        = [get_env("INSTANA_AGENT_TOKEN", ""), get_env("INSTANA_AGENT_BACKEND", "ingress-green-saas.instana.io:443")]
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
    Module = "aws-instance"
  }
}
