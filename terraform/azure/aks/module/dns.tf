# Private AKS DNS zone

# Pprivate dns zone name for AKS has to be in either of these formats:
#   private.northeurope.azmk8s.io
#   privatelink.northeurope.azmk8s.io
#  [a-zA-Z0-9-]{1,32}.private.northeurope.azmk8s.io
#  [a-zA-Z0-9-]{1,32}.privatelink.northeurope.azmk8s.io
# Please refer to https://aka.ms/aks/private-cluster for detail."
resource "azurerm_private_dns_zone" "aks-private-zone" {
  #sample: aks-shared1-dev.privatelink.northeurope.azmk8s.io
  name                = "aks-${var.cluster_name}-${var.env}.privatelink.${var.region}.azmk8s.io"
  resource_group_name = local.resource_group_name
}

# Private AKS DNS zone Managed User
resource "azurerm_user_assigned_identity" "aks-private-zone-admin" {
  name                = "aks-${local.cluster_name}-domain-admin"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_role_assignment" "aks-private-zone-admin" {
  scope                = azurerm_private_dns_zone.aks-private-zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks-private-zone-admin.principal_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks-private-zone-vpc-link" {
  name                  = "aks-${local.cluster_name}-domain2vpc-${data.azurerm_virtual_network.vnet.name}-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks-private-zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}
