# TODO as of now EUSC does not support Client VPN, so this is just a placeholder for when it will be supported.
#
# Error: creating EC2 Client VPN Endpoint: operation error EC2: CreateClientVpnEndpoint,
# https response error StatusCode: 400, RequestID: ...,
# api error InvalidAction: The action CreateClientVpnEndpoint is not valid for this web service.

locals {
  pub_ssh = file("~/.ssh/id_rsa.aws.vm.pub")
  ssh_key = file("~/.ssh/id_rsa.aws.vm")
  # current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
  region = "eusc-de-east-1"
  zone   = "eusc-de-east-1a"
}

include "root" {
  path = find_in_parent_folders("eusc.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env    = "dev"
  region = local.region
  zone   = local.zone
  # external_access_range                   = "${local.current_ip}/32"
  security_group_names = ["dev-${local.region}-ssh-http-from-vpc", "dev-${local.region}-http-from-external-access-range"]
  vpc                  = "dev-${local.region}"
  # using internal VPC DNS resolver, TODO use Route53 internal endpoints
  dns_servers = ["10.16.0.2"]
  # configuration for Linux/Ubuntu to reconfigure client host DNS resolveconf configuration
  vpn_additional_config = <<EOL
script-security 2
up /etc/openvpn/update-resolv-conf
up-restart
down /etc/openvpn/update-resolv-conf
down-pre
EOL
  subnet                = "private"
  zones = ["${local.region}a", "${local.region}b",
    # TODO eusc does not have 3 AZs yet
    # "${local.region}c"
  ]
  aws_tags = {
    Env    = "dev"
    Region = local.region
  }

}
