resource "azurerm_public_ip" "bastion" {
  name                = "${local.prefix}-bastion"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion.cidr_range]
}




resource "azurerm_bastion_host" "bastion" {
  name                = "${local.prefix}-bastion"
  location            = local.location
  resource_group_name = local.resource_group_name

  copy_paste_enabled = true

  # sku = "Standard"
  # tunneling_enabled = true
  # file_copy_enabled  = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
