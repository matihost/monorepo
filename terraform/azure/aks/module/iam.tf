# Private AKS Admin
# azurerm_kubernetes_cluster.name.identity.identity_ids assigns admin privilege on it
resource "azurerm_user_assigned_identity" "cluster-admin" {
  name                = "aks-${local.cluster_name}-admin"
  location            = local.location
  resource_group_name = local.resource_group_name
}



resource "azuread_group" "cluster-admin" {
  display_name     = "aks-${local.cluster_name}-admin"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_role_assignment" "cluster-admin" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azuread_group.cluster-admin.object_id
}


# For kubelet identity
# To avoid error:
# The cluster using user-assigned managed identity must be granted 'Managed Identity Operator' role to assign kubelet identity. You can run 'az role assignment create --assignee \u003ccontrol-plane-identity-principal-id\u003e --role 'Managed Identity Operator' --scope \u003ckubelet-identity-resource-id\u003e' to grant the permission. See https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#add-role-assignment
resource "azurerm_role_assignment" "kubelet" {
  scope                = local.resource_group_id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.cluster-admin.principal_id
}


# Service principal or user-assigned identity must be given certain permissions to resource /subscriptions.../resourceGroups/.../providers/Microsoft.Network/privateDnsZones/aks-shared1-dev.privatelink.northeurope.azmk8s.io.
# Check access result not allowed for action Microsoft.Network/privateDnsZones/read.
resource "azurerm_role_assignment" "aks-user-identity-private-zone-admin" {
  scope                = azurerm_private_dns_zone.aks-private-zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cluster-admin.principal_id
}


# resource "azurerm_role_assignment" "role_network" {
#   scope                = data.azurerm_resource_group.rg.id
#   role_definition_name = "Network Contributor"
#   principal_id         = azuread_service_principal.aro.object_id
# }
