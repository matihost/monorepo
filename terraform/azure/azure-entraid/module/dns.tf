resource "azurerm_private_dns_zone" "privatelink" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.env
}
