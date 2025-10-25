resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_ip_cidr_range]
  location            = local.location
  name                = "${local.prefix}-vnet"
  resource_group_name = local.resource_group_name
}



resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  address_prefixes     = [each.value.cidr_range]
  name                 = "${azurerm_virtual_network.vnet.name}-${each.key}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry"]

  default_outbound_access_enabled = false

  lifecycle {
    # default is true - ARO master subnet is changed afterwards to false, and it cannot be changed later
    ignore_changes = [private_link_service_network_policies_enabled]
  }
}


# By default, if there is no route table associated with subnets, azure associate "system" default one
# By creating explicit one, the effective route table is a merge of system, and explicit one.
resource "azurerm_route_table" "route_table" {
  location            = local.location
  name                = "${local.prefix}-vnet-route-table"
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet_route_table_association" "subnet" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.subnet[each.key].id
  route_table_id = azurerm_route_table.route_table.id
}

# TODO zone resilient nat gateways
# A single NAT gateway resource can't be used across multiple availability zones. To ensure zone-resiliency, it is recommended to deploy a NAT gateway resource to each availability zone and assign to subnets containing AKS clusters in each zone. For more information on this deployment model, see NAT gateway for each zone. If no zone is configured for NAT gateway,
# the default zone placement is "no zone", in which Azure places NAT gateway into a zone for you.
# https://learn.microsoft.com/en-us/azure/nat-gateway/nat-availability-zones#zonal-nat-gateway-resource-for-each-zone-in-a-region-to-create-zone-resiliency
resource "azurerm_nat_gateway" "nat" {
  name                = "${local.prefix}-natgateway"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_public_ip" "nat" {
  name                = "${local.prefix}-natgateway"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id
}


resource "azurerm_subnet_nat_gateway_association" "nat" {
  for_each = var.subnets

  subnet_id      = azurerm_subnet.subnet[each.key].id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}


# resource "azurerm_network_security_group" "example" {
#   name                = "example-nsg"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   security_rule {
#     name                       = "test123"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "example" {
#   subnet_id                 = azurerm_subnet.example.id
#   network_security_group_id = azurerm_network_security_group.example.id
# }


# resource "azurerm_route_table" "example" {
#   name                = "example-routetable"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   route {
#     name                   = "example"
#     address_prefix         = "10.100.0.0/14"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.10.1.1"
#   }
# }

# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = azurerm_subnet.example.id
#   route_table_id = azurerm_route_table.example.id
# }
