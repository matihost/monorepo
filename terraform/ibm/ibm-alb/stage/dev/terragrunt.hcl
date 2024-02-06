locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"

  # Ensure Resource Group name is in sync with Env name
  # Free Tier can use only Default One
  resource_group_id = "${run_cmd("--terragrunt-quiet", "sh", "-c", "ibmcloud resource group dev --output json | jq -r .[0].id")}"
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
  resource_group_id             = local.resource_group_id
  region                        = "eu-de"
  zone                          = "eu-de-1"
  ssh_key_id                    = "dev-eu-de-bastion-ssh"
  vpc_name                      = "dev-eu-de"
  external_access_ip            = local.current_ip
  instance_profile              = "cx2-2x4" # available instance profiles: ibmcloud is instance-profiles
  security_group_name           = "dev-eu-de-internal-only"
  public_lb_security_group_name = "dev-eu-de-bastion"
  iam_trusted_profile           = "dev-eu-de-bastion"
  subnetworks = {
    "eu-de-1" = {
      name = "dev-eu-de-1-subnet"
    },
    "eu-de-2" = {
      name = "dev-eu-de-2-subnet"
    },
    "eu-de-3" = {
      name = "dev-eu-de-3-subnet"
    },
  },
}
