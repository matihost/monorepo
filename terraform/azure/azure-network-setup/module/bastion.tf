resource "azurerm_public_ip" "bastion" {
  count = var.managed_bastion != null ? 1 : 0

  name                = "${local.prefix}-bastion"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}


resource "azurerm_subnet" "bastion" {
  count = var.managed_bastion != null ? 1 : 0

  # Mandatory name for subnet where bastion resides
  name                 = "AzureBastionSubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.managed_bastion.cidr_range]
}



resource "azurerm_network_security_group" "bastion" {
  count = var.managed_bastion != null ? 1 : 0

  name                = "${local.prefix}-bastion"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowHttpsInBound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowTunnellingThroughBastionInBound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701", "8888"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureCloudCommunicationOutBound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = "AzureCloud"
  }


  security_rule {
    name                       = "AllowSSHandRDPandProxyOutBound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389", "8888"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowBastionHostCommunicationOutBound"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowGetSessionInformationOutBound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}


resource "azurerm_subnet_network_security_group_association" "bastion" {
  count = var.managed_bastion != null ? 1 : 0

  subnet_id                 = azurerm_subnet.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}

resource "azurerm_bastion_host" "bastion" {
  count = var.managed_bastion != null ? 1 : 0

  name                = "${local.prefix}-bastion"
  location            = local.location
  resource_group_name = local.resource_group_name

  copy_paste_enabled = true


  # In order to ssh to instance via CLI: az network bastion ssh
  # Bastion Host SKU must be Standard or Premium and Native Client must be enabled.
  sku               = "Standard"
  tunneling_enabled = true
  file_copy_enabled = true


  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags
}
