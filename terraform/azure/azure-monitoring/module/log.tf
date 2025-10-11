# TODO there is a weird behavior that accessing same workspace created by CLI/GUI or via Terraforn
# leads that Terraform one is not accessible via its primarySharedKey
# but when object is imported to Terraform there is no difference...
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefix}-logging"
  location            = local.location
  resource_group_name = local.resource_group_name

  retention_in_days = 30 // values range: [30, 730]
  # immediate_data_purge_on_30_days_enabled = true

  # daily_quota_gb = 5 # GB, -1 to disable quota

  internet_ingestion_enabled = true
  internet_query_enabled     = true
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  location              = local.location
  resource_group_name   = local.resource_group_name

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}
