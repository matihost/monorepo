resource "null_resource" "cluster-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/configure-cluster.sh '${azurerm_kubernetes_cluster.aks.resource_group_name}' '${local.subscription_name}' '${local.tenant_id}' '${azurerm_kubernetes_cluster.aks.name}' '${var.region}' '${azurerm_container_registry.aks.name}' '${jsonencode(var.namespaces)}'"
  }

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.user,
    azuread_group.ns-edit,
    azuread_group.ns-view,
    azurerm_federated_identity_credential.ns-workload-identity-edit-federation,
    azurerm_role_assignment.ns-key_vault-creator-for-editors,
    azuread_group_member.ns-workload-identity-edit-membership,
    azurerm_role_assignment.ns-key_vault-creator-for-viewers

  ]
}

# Group edit per NS with the following properties:
# * reader for entire RG where cluster is located
# * secret officer for dedicate per AKS/NS Key Vault
# * AKS RBAC NS edit binding - aka members can act as edit for particular NS
# Managed members here:
# * owner
# * user assigned identity for Workload Identity federated with K8S NS app SA - aka NS app SA has same permissions as this group
resource "azuread_group" "ns-edit" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }


  display_name     = "aks-${local.cluster_name}-ns-${each.key}-edit"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "ns-edit-owner-membership" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  group_object_id  = azuread_group.ns-edit[each.key].object_id
  member_object_id = data.azuread_client_config.current.object_id
}

resource "azuread_group" "ns-view" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  display_name     = "aks-${local.cluster_name}-ns-${each.key}-view"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group_member" "ns-view-owner-membership" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  group_object_id  = azuread_group.ns-view[each.key].object_id
  member_object_id = data.azuread_client_config.current.object_id
}

# Key Vault per Namespace
resource "azurerm_key_vault" "ns-key-vault" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  # Vault names are globally unique.
  # The vault name should be string of 3 to 24 characters and can contain only numbers (0-9), letters (a-z, A-Z), and hyphens (-)
  name = "${local.cluster_name}-${substr(sha256(each.key), 0, 6)}"

  tags = {
    "purpose" : "Key Vault for AKS: ${local.cluster_name} NS: ${each.key} secrets"
  }

  location            = var.region
  resource_group_name = local.resource_group_name

  enabled_for_disk_encryption = true
  tenant_id                   = local.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  # TODO enable private endpoint connectivity
  # public_network_access_enabled = false
}


resource "azurerm_role_assignment" "ns-key_vault-creator-for-editors" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  scope = azurerm_key_vault.ns-key-vault[each.key].id
  # The Key Vault Contributor role is for management plane operations only to manage key vaults.
  # It does not allow access to keys, secrets and certificates (if you need use Key Vault Administrator)
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_group.ns-edit[each.key].object_id
}

resource "azurerm_role_assignment" "ns-rg-reader-for-editors" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  scope                = local.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azuread_group.ns-edit[each.key].object_id
}


resource "azurerm_role_assignment" "ns-key_vault-creator-for-viewers" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  scope                = azurerm_key_vault.ns-key-vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_group.ns-view[each.key].object_id
}



# Workload Identity with User Assigned Identity
# Create one per NS and place it to edit group
resource "azurerm_user_assigned_identity" "ns-workload-identity-edit" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  name                = "aks-${local.cluster_name}-ns-${each.key}-edit"
  location            = var.region
  resource_group_name = local.resource_group_name
}

resource "azuread_group_member" "ns-workload-identity-edit-membership" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  group_object_id  = azuread_group.ns-edit[each.key].object_id
  member_object_id = azurerm_user_assigned_identity.ns-workload-identity-edit[each.key].principal_id
}


# Mapping SA to User Assigned Identity
resource "azurerm_federated_identity_credential" "ns-workload-identity-edit-federation" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  name                = "${azurerm_user_assigned_identity.ns-workload-identity-edit[each.key].name}-federated-identity"
  resource_group_name = local.resource_group_name
  parent_id           = azurerm_user_assigned_identity.ns-workload-identity-edit[each.key].id

  issuer   = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject  = "system:serviceaccount:${each.key}:app"
  audience = ["api://AzureADTokenExchange"]
}
