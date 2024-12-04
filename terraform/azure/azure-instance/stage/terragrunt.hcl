locals {
  subscription_id       = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "id", "-o", "tsv")}"
  subscription_name     = "${run_cmd("--terragrunt-quiet", "az", "account", "list", "--query", "[?id=='${local.subscription_id}'].name", "-o", "tsv", "--all")}"
  state_resource_group  = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_rg_name.sh"))}"
  state_storage_account = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))}"
  state_container       = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_container_name.sh"))}"

  tenant_id             = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "tenantId", "-o", "tsv")}"
  container_instance_id = "${run_cmd("--terragrunt-quiet", "az", "ad", "sp", "list", "--display-name", "Azure Container Instance", "--query", "[].id", "-o", "tsv")}"

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
    tenant_id            = local.tenant_id
    subscription_id      = local.subscription_id
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  subscription_id = "${local.subscription_id}"
  resource_provider_registrations = "extended"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
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
  container_instance_id = local.container_instance_id
}
