locals {
  subscription_id       = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "id", "-o", "tsv")}"
  subscription_name     = "${run_cmd("--terragrunt-quiet", "az", "account", "list", "--query", "[?id=='${local.subscription_id}'].name", "-o", "tsv")}"
  state_resource_group  = "${local.subscription_name}-gitops"
  state_storage_account = "${local.subscription_name}gitops"
  tenant_id             = "${run_cmd("--terragrunt-quiet", "az", "account", "show", "--query", "tenantId", "-o", "tsv")}"
  region                = "polandcentral"
  zone                  = "polandcentral-az1"
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
    container_name       = local.subscription_name
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
  region                = local.region
  zone                  = local.zone
}
