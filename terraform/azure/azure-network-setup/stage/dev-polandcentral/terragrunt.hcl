# Warning: CloudShell cannot use StoraAccount, nor VNet from Poland-Central
# Attempt to create CloudShell pointing to Storage Accout Share or VNet in Poland Central region ends with:
#
# Subscription: ....
# Resource group: ....
# Storage account: cshell2dev2polc25c583b
# File share: shared-cloudshell-storage
# Region: undefined

# Error details
# Code: UserSettingsInvalidLocation
# Message: The user settings preferred location '<null>' is invalid. The allowed locations are 'westus,southcentralus,eastus,northeurope,westeurope,centralindia,southeastasia,westcentralus,eastus2euap,centraluseuap'.
# Correlation ID: ....
#

include {
  path = find_in_parent_folders()
}

locals {
  env             = "dev"
  storage_account = "cshell2${local.env}2polc2${substr(uuidv5("dns", run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))), 0, 6)}"
  region          = "polandcentral"
  zone            = "polandcentral-az1"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                = "dev"
  region             = local.region
  zone               = local.zone
  vnet_ip_cidr_range = "10.1.0.0/16"
  cloudshell = {
    cidr_range           = "10.1.0.0/24"
    storage_account_name = local.storage_account
    shares               = ["shared-cloudshell-storage"]
  }
  relay = {
    cidr_range = "10.1.1.0/24"
  }
  storage = {
    cidr_range = "10.1.2.0/24"
  }
  subnets = {
    "vms" = {
      cidr_range = "10.1.32.0/19"
    },
    "containers" = {
      cidr_range = "10.1.64.0/19"
    }
  }
}
