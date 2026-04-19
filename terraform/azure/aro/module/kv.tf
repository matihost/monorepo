resource "azuread_application" "kv" {
  display_name = "${local.cluster_name}-kv"
  description  = "ARO cluster : ${local.cluster_name} in resource group: ${local.resource_group_name} for KV access"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "kv-rbac" {
  display_name   = "rbac"
  application_id = azuread_application.kv.id
}


resource "azuread_service_principal" "kv" {
  description = "ARO cluster: ${local.cluster_name} in resource group: ${local.resource_group_name} for KV access"
  client_id   = azuread_application.kv.client_id
  owners      = [data.azuread_client_config.current.object_id]
}

data "azurerm_key_vault" "kv" {
  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
}


resource "azurerm_role_assignment" "kv-cert-user" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azuread_service_principal.kv.object_id
}

resource "azurerm_role_assignment" "kv-secrets-user" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.kv.object_id
}

locals {
  kv_name          = data.azurerm_key_vault.kv.name
  kv_client_secret = nonsensitive(azuread_application_password.kv-rbac.value)
  kv_client_id     = azuread_application.kv.client_id
}
