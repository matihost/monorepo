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
  env         = "dev"
  region      = "us-east-1"
  zone        = "us-east-1a"
  ssh_pub_key = local.pub_ssh
  ssh_key     = local.ssh_key
  # external_access_range                   = "${local.current_ip}/32"
  create_sample_instance                  = true
  create_ssm_private_access_vpc_endpoints = true # WARNING: switch to true to be able to SSM to private EC2 instances
  create_s3_endpoint                      = true
  ec2_instance_type                       = "t4g.small" # or t3.micro
  ec2_architecture                        = "arm64"     # or x86_64
  aws_tags = {
    Env    = "dev"
    Region = "us-east-1"
  }
  vpc_ip_cidr_range = "10.0.0.0/16"
  zones = {
    "us-east-1a" = {
      public_ip_cidr_range  = "10.0.0.0/22"
      private_ip_cidr_range = "10.0.32.0/19"
    },
    "us-east-1b" = {
      public_ip_cidr_range  = "10.0.4.0/22"
      private_ip_cidr_range = "10.0.64.0/19"
    },
    "us-east-1c" = {
      public_ip_cidr_range  = "10.0.8.0/22"
      private_ip_cidr_range = "10.0.96.0/19"
    },
  },

  # To which VPC/regions to send peering connection request
  # vpc_peering_regions = ["eu-central-1"]
  # change finish_peering to true for requestor side - when acceptor side accepted peering
  # finish_peering = true

  # From which VPC/regions to accept peering connection request
  # vpc_peering_acceptance_regions = [ "us-east-1"]
}
