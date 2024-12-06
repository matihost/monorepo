data "azurerm_virtual_network" "vnet" {
  name                = "${local.prefix}-vnet"
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}

locals {
  vm_name = "${local.prefix}-${var.name}"
}


resource "azurerm_ssh_public_key" "ssh" {
  name                = "${local.vm_name}-ssh"
  location            = local.location
  resource_group_name = local.resource_group_name
  public_key          = var.ssh_pub_key
}


resource "azurerm_key_vault_secret" "ssh" {
  name         = local.vm_name
  value        = var.ssh_key
  key_vault_id = data.azurerm_key_vault.key_vault.id
}


resource "azurerm_network_interface" "nic" {
  name                = "${local.vm_name}-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux" {
  name     = local.vm_name
  location = local.location
  # Do not provide zone to let Azure choose zone where instance type is present...
  # zone                = var.zone
  resource_group_name = local.resource_group_name
  size                = var.size
  admin_username      = var.image.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  priority        = var.spot ? "Spot" : "Regular"
  eviction_policy = var.spot ? "Delete" : null

  # TODO test user_data instead
  # https://learn.microsoft.com/en-us/azure/virtual-machines/user-data
  custom_data = base64encode(templatestring(var.user_data_template, {
    ssh_key        = base64encode(var.ssh_key),
    ssh_pub        = base64encode(var.ssh_pub_key),
    admin_username = var.image.admin_username
  }))

  admin_ssh_key {
    username   = var.image.admin_username
    public_key = azurerm_ssh_public_key.ssh.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }
}
