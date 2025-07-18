locals {
  pub_ssh = file("~/.ssh/id_rsa.aws.vm.pub")
  ssh_key = file("~/.ssh/id_rsa.aws.vm")
  # current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env    = "dev"
  region = "us-east-1"
  zone   = "us-east-1a"
  # external_access_range                   = "${local.current_ip}/32"
  security_group_names = ["dev-us-east-1-ssh-http-from-vpc", "dev-us-east-1-http-from-external-access-range"]
  vpc                  = "dev-us-east-1"
  # using internal VPC DNS resolver, TODO use Route53 internal endpoints
  dns_servers = ["10.0.0.2"]
  # configuration for Linux/Ubuntu to reconfigure client host DNS resolveconf configuration
  vpn_additional_config = <<EOL
script-security 2
up /etc/openvpn/update-resolv-conf
up-restart
down /etc/openvpn/update-resolv-conf
down-pre
EOL
  subnet                = "private"
  zones                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  aws_tags = {
    Env    = "dev"
    Region = "us-east-1"
  }

}
