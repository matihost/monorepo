resource "random_id" "backup" {
  byte_length = 2
}

resource "azurerm_storage_account" "backup" {
  name                       = substr(replace("${local.cluster_name}${random_id.backup.hex}arobckp", "-", ""), 0, 24)
  resource_group_name        = local.resource_group_name
  location                   = local.location
  account_tier               = "Standard"
  account_replication_type   = "GRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  # TODO disable public network access, requires private endpoint connections, and figure out how to force Velero to use it
  public_network_access_enabled = true
  shared_access_key_enabled     = false

  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_storage_container" "backup" {
  name                  = "aro-backup"
  storage_account_id    = azurerm_storage_account.backup.id
  container_access_type = "private"
}



resource "azuread_application" "backup" {
  display_name = "${local.cluster_name}-aro-backup"
  description  = "ARO cluster : ${local.cluster_name} in resource group: ${local.resource_group_name} for backup"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "backup-rbac" {
  display_name   = "rbac"
  application_id = azuread_application.backup.id
}


resource "azuread_service_principal" "backup" {
  description = "ARO cluster: ${local.cluster_name} in resource group: ${local.resource_group_name} for backup"
  client_id   = azuread_application.backup.client_id
  owners      = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "backup" {
  service_principal_id = azuread_service_principal.aro.id
}


resource "azurerm_role_assignment" "backup-contributor" {
  scope                = azurerm_storage_account.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.backup.object_id
}

resource "azurerm_role_assignment" "backup-rg-contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.backup.object_id
}


#  give access to owner of the blob as well
resource "azurerm_role_assignment" "owner-backup-contributor" {
  scope                = azurerm_storage_account.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

locals {
  backup_client_secret = nonsensitive(azuread_application_password.backup-rbac.value)
  backup_client_id     = azuread_application.backup.client_id
}
