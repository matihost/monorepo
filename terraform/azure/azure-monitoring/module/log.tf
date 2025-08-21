resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefix}-log"
  location            = local.location
  resource_group_name = local.resource_group_name

  retention_in_days                       = 30 // values range: [30, 730]
  immediate_data_purge_on_30_days_enabled = true

  daily_quota_gb = 5 # GB, -1 to disable quota

  # internet_ingestion_enabled = true
  # internet_query_enabled = true
}

resource "azurerm_log_analytics_solution" "containers" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  location              = local.location
  resource_group_name   = local.resource_group_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}
