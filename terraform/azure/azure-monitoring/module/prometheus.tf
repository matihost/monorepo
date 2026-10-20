resource "azurerm_monitor_workspace" "monitor" {
  name                = "${local.prefix}-monitor"
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                = "${local.prefix}-grafana"
  location            = local.location
  resource_group_name = local.resource_group_name
  # azurerm 5 accepts only 12 and 13 (11 was dropped), 13 is the latest
  grafana_major_version = 13
  api_key_enabled       = true

  # The following properties have an input value that is inconsistent with sku type Essential: DeterministicOutboundIP
  # deterministic_outbound_ip_enabled is not supported in Essential sku
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = false

  sku                     = "Standard" # or Essential
  zone_redundancy_enabled = false      # or true

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.monitor.id
  }
}
