locals {
  key_vault_name = "${local.prefix}-${substr(sha256(local.subscription_name), 0, 7)}"
}

resource "azurerm_key_vault" "key_vault" {

  # Vault names are globally unique.
  # The vault name should be string of 3 to 24 characters and can contain only numbers (0-9), letters (a-z, A-Z), and hyphens (-)
  name                        = local.key_vault_name
  location                    = var.region
  resource_group_name         = var.env
  enabled_for_disk_encryption = true
  tenant_id                   = local.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  # TODO enable private endpooint connectivity
  # public_network_access_enabled = false
}

# By default noone, even creator of the key value, cannot create secrets in the key vault
# Azure recommends:
# Our recommendation is to use a vault per application per environment (Development, Pre-Production, and Production)
# with roles assigned at the key vault scope.
#
# https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#best-practices-for-individual-keys-secrets-and-certificates-role-assignments
resource "azurerm_role_assignment" "key_vault-creator" {
  scope = azurerm_key_vault.key_vault.id
  # The Key Vault Contributor role is for management plane operations only to manage key vaults.
  # It does not allow access to keys, secrets and certificates.
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# TODO add variable to add more users, service principals, and managed identities to access key-vault
