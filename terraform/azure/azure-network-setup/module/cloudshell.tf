resource "azurerm_subnet" "cloudshell" {

  address_prefixes     = [var.cloudshell.cidr_range]
  name                 = "${azurerm_virtual_network.vnet.name}-cloudshell"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "CloudShellDelegation"
    service_delegation {
      # even it is optional, it appears in a state and TF consider it as a change
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.ContainerInstance/containerGroups"
    }
  }

  default_outbound_access_enabled = false
}


resource "azurerm_network_security_group" "cloudshell" {
  name                = azurerm_subnet.cloudshell.name
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "DenyIntraSubnetTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.cloudshell.cidr_range
    destination_address_prefix = var.cloudshell.cidr_range
  }
}


resource "azurerm_subnet_nat_gateway_association" "cloudshell" {
  subnet_id      = azurerm_subnet.cloudshell.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_network_security_group_association" "cloudshell" {
  subnet_id                 = azurerm_subnet.cloudshell.id
  network_security_group_id = azurerm_network_security_group.cloudshell.id
}

resource "azurerm_network_profile" "cloudshell" {
  name                = azurerm_subnet.cloudshell.name
  location            = local.location
  resource_group_name = local.resource_group_name

  container_network_interface {
    name = "eth-${azurerm_subnet.cloudshell.name}"

    ip_configuration {
      name      = "ipconfig-${azurerm_subnet.cloudshell.name}"
      subnet_id = azurerm_subnet.cloudshell.id
    }
  }
}


resource "azurerm_role_assignment" "cloudshell" {
  scope                = azurerm_network_profile.cloudshell.id
  role_definition_name = "Network Contributor"
  principal_id         = var.container_instance_id
}


resource "azurerm_relay_namespace" "relay" {
  name                = "${azurerm_virtual_network.vnet.name}-relay"
  location            = local.location
  resource_group_name = local.resource_group_name

  sku_name = "Standard"
}


resource "azurerm_role_assignment" "relay" {
  scope                = azurerm_relay_namespace.relay.id
  role_definition_name = "Contributor"
  principal_id         = var.container_instance_id
}


resource "azurerm_subnet" "relay" {

  address_prefixes     = [var.relay.cidr_range]
  name                 = "${azurerm_virtual_network.vnet.name}-relay"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  default_outbound_access_enabled = false

  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true

  depends_on = [azurerm_subnet.cloudshell]
}


resource "azurerm_subnet_nat_gateway_association" "relay" {
  subnet_id      = azurerm_subnet.relay.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}


resource "azurerm_private_endpoint" "relay" {
  name                = azurerm_relay_namespace.relay.name
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = azurerm_subnet.relay.id

  private_service_connection {
    name                           = "${azurerm_relay_namespace.relay.name}-privateserviceconnection"
    private_connection_resource_id = azurerm_relay_namespace.relay.id
    subresource_names              = ["namespace"]
    is_manual_connection           = false
  }
}


# Managed in azure-entraid module per resource group
data "azurerm_private_dns_zone" "privatelink" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = local.resource_group_name
}


resource "azurerm_private_dns_a_record" "relay" {
  name                = azurerm_relay_namespace.relay.name
  zone_name           = data.azurerm_private_dns_zone.privatelink.name
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.relay.custom_dns_configs[0].ip_addresses[0]]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = azurerm_relay_namespace.relay.name
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.privatelink.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Storage Account has to be from the same resource group Cloud Shell attached VNet/Subnet is
resource "azurerm_storage_account" "cloudshell" {
  name                = var.cloudshell.storage_account_name
  resource_group_name = local.resource_group_name

  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2" # CloudShell are ok with SMBA, Premium if NFSv4 is needed

  # TODO Azure adds a tag, is it mandatory ?
  # "ms-resource-usage" = "azure-cloud-shell"
  lifecycle {
    ignore_changes = [tags]
  }
}

# TODO ensure only access is from VNet subnets
#
# resource "azurerm_storage_account_network_rules" "cloudshell" {
#   storage_account_id = azurerm_storage_account.cloudshell.id

#   default_action             = "Deny"
#   virtual_network_subnet_ids = [azurerm_subnet.cloudshell.id, azurerm_subnet.storage.id]
#   bypass                     = ["None"]
# }


resource "azurerm_storage_share" "cloudshell" {
  for_each = toset(var.cloudshell.shares)

  name               = each.key
  storage_account_id = azurerm_storage_account.cloudshell.id
  quota              = 6 # GB
}
