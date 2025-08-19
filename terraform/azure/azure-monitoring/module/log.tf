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
