locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
  pub_ssh    = file("~/.ssh/id_rsa.aws.vm.pub")
  ssh_key    = file("~/.ssh/id_rsa.aws.vm")
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
  name               = "vm"
  vpc                = "dev-us-east-1" # or default to choose default VPC
  subnet             = "public"
  region             = "us-east-1"
  zone               = "us-east-1a"
  ssh_pub_key        = local.pub_ssh
  ssh_key            = local.ssh_key
  external_access_ip = local.current_ip
  instance_profile   = ""
  ec2_instance_type  = "t4g.small" # or t3.micro
  ec2_architecture   = "arm64"     # or x86_64
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
    Module = "aws-instance"
  }
}
