data "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                 = "${local.prefix}-acr-dns-link"
  private_dns_zone_id  = data.azurerm_private_dns_zone.acr.id
  virtual_network_id   = azurerm_virtual_network.vnet.id
  registration_enabled = false
}
