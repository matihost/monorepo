resource "azurerm_private_dns_zone" "privatelink" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.env
}


resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.env
}
