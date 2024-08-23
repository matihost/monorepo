resource "azurerm_resource_group" "rg" {
  name     = var.env
  location = var.region
}
