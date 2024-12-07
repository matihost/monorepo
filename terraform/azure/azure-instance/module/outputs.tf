data "azurerm_bastion_host" "bastion" {
  name                = "${local.prefix}-bastion"
  resource_group_name = local.resource_group_name
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.linux.id
}

output "bastion_name" {
  value = data.azurerm_bastion_host.bastion.name
}
