data "azurerm_policy_definition_built_in" "vmsize" {
  display_name = "Allowed virtual machine size SKUs"
}


resource "azurerm_resource_group_policy_assignment" "vmsize" {
  name                 = "allowed-vm-sizes"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition_built_in.vmsize.id
  enforce              = var.enforce_policies
  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.vm_sizes
    }
  })
}


data "azurerm_policy_definition_built_in" "locations" {
  display_name = "Allowed locations"
}

resource "azurerm_resource_group_policy_assignment" "locations" {
  name                 = "allowed-regions"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition_built_in.locations.id
  enforce              = var.enforce_policies
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.locations
    }
  })
}
