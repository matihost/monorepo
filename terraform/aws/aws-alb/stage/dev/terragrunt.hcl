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
  env                           = "dev"
  region                        = "us-east-1"
  zone                          = "us-east-1a"
  external_access_ip            = local.current_ip
  instance_profile              = "SSM-EC2"
  ec2_instance_type             = "t4g.small" # or t3.micro
  ec2_architecture              = "arm64"     # or x86_64
  ssh_key_id                    = "dev-us-east-1-bastion-ssh"
  ec2_security_group_name       = "dev-ssh-http-from-vpc"
  public_lb_security_group_name = "dev-http-from-external-access-range"
  vpc_name                      = "dev-us-east-1"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
