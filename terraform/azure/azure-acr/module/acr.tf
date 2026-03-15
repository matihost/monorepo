resource "azurerm_container_registry" "acr" {
  name                          = replace("${local.prefix}${var.name}", "-", "")
  location                      = local.location
  resource_group_name           = local.resource_group_name
  sku                           = "Premium"
  zone_redundancy_enabled       = true
  public_network_access_enabled = var.public

  # whether to expose break-glass admin access to ACR, normally only EntraId access possible
  admin_enabled = var.admin_enabled

  lifecycle {
    ignore_changes = [tags, ]
  }
  tags = var.tags
}

data "azurerm_subnet" "private-endpoints-subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.private_endpoints_subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}

data "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_endpoint" "acr" {
  name                          = azurerm_container_registry.acr.name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  subnet_id                     = data.azurerm_subnet.private-endpoints-subnet.id
  custom_network_interface_name = "nic${azurerm_container_registry.acr.name}"

  private_service_connection {
    name                           = "config"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "acr-zonegroup"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.acr.id
    ]
  }

}


output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# Available when admin=true, otherwise only EntraID access available
#
output "acr_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
