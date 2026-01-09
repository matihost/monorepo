locals {
  subscription_id       = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "id", "-o", "tsv")}"
  subscription_name     = "${run_cmd("--terragrunt-quiet", "az", "account", "list", "--query", "[?id=='${local.subscription_id}'].name", "-o", "tsv", "--all")}"
  state_resource_group  = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_rg_name.sh"))}"
  state_storage_account = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))}"
  state_container       = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_container_name.sh"))}"

  tenant_id = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "tenantId", "-o", "tsv")}"
}

remote_state {
  backend = "azurerm"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = local.state_resource_group
    storage_account_name = local.state_storage_account
    container_name       = local.state_container
    key                  = "${basename(abspath("${get_parent_terragrunt_dir()}/.."))}/${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}/terraform.tfstate"
    # providing both tenant_id and subscription_id
    # ends with error:
    # error listing access keys on the storage account: AzureCLICredential: ERROR: Please specify only one of subscription and tenant, not both
    #
    # tenant_id            = local.tenant_id
    subscription_id = local.subscription_id
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  subscription_id = "${local.subscription_id}"
  tenant_id       = "${local.tenant_id}"

  # assuming user is either logged via az cli (default)
  # or
  # env variables for Service Principa/Managed Identity are provided:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity

  resource_provider_registrations = "extended"
  resource_providers_to_register = [
      "Microsoft.RedHatOpenShift",
  ]
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {
  tenant_id = "${local.tenant_id}"
}
EOF
}

inputs = {
  tenant_id             = local.tenant_id
  subscription_id       = local.subscription_id
  subscription_name     = local.subscription_name
  state_resource_group  = local.state_resource_group
  state_storage_account = local.state_storage_account
  state_container       = local.state_container
}
