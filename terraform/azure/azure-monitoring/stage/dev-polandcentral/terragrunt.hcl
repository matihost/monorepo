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

include "root" {
  path = find_in_parent_folders("root.hcl")
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
  env    = "dev"
  region = local.region
  zone   = local.zone
}
