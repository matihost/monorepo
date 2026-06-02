resource "azurerm_user_assigned_identity" "vm-identity" {
  name                = local.vm_name
  location            = local.location
  resource_group_name = local.resource_group_name
}

data "azurerm_storage_account" "backup" {
  count               = var.backup_storage_account_name != null ? 1 : 0
  name                = var.backup_storage_account_name
  resource_group_name = var.backup_storage_account_rg
}


resource "azurerm_role_assignment" "backup-contributor" {
  count                = var.backup_storage_account_name != null ? 1 : 0
  scope                = data.azurerm_storage_account.backup[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.vm-identity.principal_id
}


resource "azurerm_role_assignment" "system-identity-backup-contributor" {
  scope                = data.azurerm_storage_account.backup[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine.linux.identity[0].principal_id
}
