resource "azurerm_container_registry" "aks" {
  # name has to be globally unique
  name                          = replace(local.cluster_name, "-", "")
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = "Premium"
  zone_redundancy_enabled       = true
  public_network_access_enabled = var.public

  # whether to expose break-glass admin access to ACR, normally only EntraId access possible
  admin_enabled = false

  lifecycle {
    ignore_changes = [tags, ]
  }
}

# attaching Container Registry to AKS cluster
resource "azurerm_role_assignment" "aks-cr" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.aks.id
  skip_service_principal_aad_check = true
}


resource "azurerm_private_endpoint" "aks-cr" {
  name                          = azurerm_container_registry.aks.name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = data.azurerm_subnet.system-subnet.id
  custom_network_interface_name = "nic${azurerm_container_registry.aks.name}"

  private_service_connection {
    name                           = "config"
    private_connection_resource_id = azurerm_container_registry.aks.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  # TODO ?
  # private_dns_zone_group {
  #   name                 = "example-dns-zone-group"
  #   private_dns_zone_ids = [azurerm_private_dns_zone.example.id]
  # }
}


output "acr_name" {
  value = azurerm_container_registry.aks.name
}


output "acr_login_server" {
  value = azurerm_container_registry.aks.login_server
}

# Available when admin=true, otherwise only EntraID access available
#
# output "acr_username" {
#   value = azurerm_container_registry.example.admin_username
# }

# output "acr_password" {
#   value = azurerm_container_registry.example.admin_password
#   sensitive = true
# }
