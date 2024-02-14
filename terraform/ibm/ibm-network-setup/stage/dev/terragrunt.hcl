locals {
  pub_ssh = file("~/.ssh/id_rsa.ibm.vm.pub")
  ssh_key = file("~/.ssh/id_rsa.ibm.vm")

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
  env                    = "dev"
  resource_group_id      = local.resource_group_id
  region                 = "eu-de"
  zone                   = "eu-de-1"
  ssh_pub_key            = local.pub_ssh
  ssh_key                = local.ssh_key
  create_sample_instance = false
  instance_profile       = "cx2-2x4" # available instance profiles: ibmcloud is instance-profiles
  tags = {
    Env    = "dev"
    Region = "eu-de"
  }

  zones = {
    # VPC address range: "10.0.0.0/16"
    # available zones: ibmcloud is zones
    "eu-de-1" = {
      ip_cidr_range = "10.0.32.0/19"
    },
    "eu-de-2" = {
      ip_cidr_range = "10.0.64.0/19"
    },
    "eu-de-3" = {
      ip_cidr_range = "10.0.96.0/19"
    },
  },
}
