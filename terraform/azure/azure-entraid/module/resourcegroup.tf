resource "azurerm_resource_group" "rg" {
  name = var.env

  # "Why does a resource group need a location? And, if the resources can have different locations than the resource group,
  #  why does the resource group location matter at all?"
  #
  # The resource group stores metadata about the resources. Therefore, when you specify a location for the resource group,
  # you're specifying where that metadata is stored.
  # For compliance reasons, you may need to ensure that your data is stored in a particular region.
  location = var.region
}
