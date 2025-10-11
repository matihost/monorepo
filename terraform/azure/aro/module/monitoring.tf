data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefix}-log"
  resource_group_name = local.resource_group_name
}


locals {
  log_analytics_workspace_id                 = data.azurerm_log_analytics_workspace.workspace.workspace_id
  log_analytics_workspace_primary_shared_key = nonsensitive(data.azurerm_log_analytics_workspace.workspace.primary_shared_key)
}
