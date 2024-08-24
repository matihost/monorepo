data "azurerm_policy_definition_built_in" "vmsize" {
  display_name = "Allowed virtual machine size SKUs"
}


resource "azurerm_subscription_policy_assignment" "vmsize" {
  name                 = "allowed-vm-sizes"
  subscription_id      = local.subscription_id
  policy_definition_id = data.azurerm_policy_definition_built_in.vmsize.id
  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.vm_sizes
    }
  })
}


data "azurerm_policy_definition_built_in" "locations" {
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "locations" {
  name                 = "allowed-regions"
  subscription_id      = local.subscription_id
  policy_definition_id = data.azurerm_policy_definition_built_in.locations.id
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.locations
    }
  })
}
