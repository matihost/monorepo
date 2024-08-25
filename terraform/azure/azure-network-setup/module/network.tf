resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_ip_cidr_range]
  location            = local.resource_group_location
  name                = "${local.prefix}-vnet"
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  address_prefixes     = [each.value.cidr_range]
  name                 = "${azurerm_virtual_network.vnet.name}-${each.key}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Sql"]

  default_outbound_access_enabled = false
}


resource "azurerm_nat_gateway" "nat" {
  name                = "${local.prefix}-natgateway"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet_nat_gateway_association" "nat" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
