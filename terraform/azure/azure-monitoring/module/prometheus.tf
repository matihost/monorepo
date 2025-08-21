resource "azurerm_monitor_workspace" "monitor" {
  name                = "${local.prefix}-monitor"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                  = "${local.prefix}-grafana"
  location              = local.location
  resource_group_name   = local.resource_group_name
  grafana_major_version = 11
  api_key_enabled       = true

  # The following properties have an input value that is inconsistent with sku type Essential: DeterministicOutboundIP
  # deterministic_outbound_ip_enabled is not supported in Essential sku
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = false

  sku                     = "Essential" # or Standard
  zone_redundancy_enabled = false       # or true

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.monitor.id
  }
}
