# Log Analytics Workspace to forward logs
data "azurerm_log_analytics_workspace" "workspace" {
  name                = "${local.prefix}-logging"
  resource_group_name = local.resource_group_name
}


locals {
  log_analytics_workspace_id                 = data.azurerm_log_analytics_workspace.workspace.workspace_id
  log_analytics_workspace_primary_shared_key = nonsensitive(data.azurerm_log_analytics_workspace.workspace.primary_shared_key)
}

# Forwarding metrics to Azure Monitor (aka managed azure prometheus)
resource "azuread_application" "aro-metrics-publisher" {
  display_name = "${local.cluster_name}-aro-metrics-publisher"
  description  = "ARO cluster: ${local.cluster_name} metrics publisher tp Azure Monitor "
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "aro-metrics-publisher-client-secret" {
  display_name   = "rbac"
  application_id = azuread_application.aro-metrics-publisher.id
}

locals {
  azure_monitor_dcr_id            = data.azurerm_monitor_data_collection_rule.monitor-dcr.immutable_id
  azure_monitor_ingestion_url     = data.azurerm_monitor_data_collection_endpoint.monitor-dce.metrics_ingestion_endpoint
  metrics_publisher_client_secret = nonsensitive(azuread_application_password.aro-metrics-publisher-client-secret.value)
  metrics_publisher_client_id     = azuread_application.aro-metrics-publisher.client_id
}

resource "azuread_service_principal" "aro-metrics-publisher-sp" {
  client_id = azuread_application.aro-metrics-publisher.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "aro-metrics-publisher-sp-pass" {
  service_principal_id = azuread_service_principal.aro-metrics-publisher-sp.id
}


data "azurerm_monitor_workspace" "monitor" {
  name                = "${local.prefix}-monitor"
  resource_group_name = local.resource_group_name
}


# When you create an Azure Monitor workspace,
# by default a data collection rule and a data collection endpoint in the form <azure-monitor-workspace-name>
# will automatically be created in a resource group in the form MA_<azure-monitor-workspace-name>_<location>_managed.
data "azurerm_monitor_data_collection_rule" "monitor-dcr" {
  name                = "${local.prefix}-monitor"
  resource_group_name = "MA_${local.prefix}-monitor_${var.region}_managed"
}


resource "azurerm_role_assignment" "aro-metrics-publisher-sp" {
  scope                = data.azurerm_monitor_data_collection_rule.monitor-dcr.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azuread_service_principal.aro-metrics-publisher-sp.object_id
}


data "azurerm_monitor_data_collection_endpoint" "monitor-dce" {
  name                = "${local.prefix}-monitor"
  resource_group_name = "MA_${local.prefix}-monitor_${var.region}_managed"
}


data "azurerm_monitor_action_group" "default" {
  name                = "${local.prefix}-default"
  resource_group_name = local.resource_group_name
}


resource "azurerm_monitor_alert_prometheus_rule_group" "down-alert" {
  name                = "${azurerm_redhat_openshift_cluster.aro.name}-down"
  location            = local.location
  resource_group_name = local.resource_group_name
  cluster_name        = azurerm_redhat_openshift_cluster.aro.name
  description         = "Triggers when ARO cluster ${azurerm_redhat_openshift_cluster.aro.name} is down for 15 minutes"

  interval = "PT15M"
  scopes   = [data.azurerm_monitor_workspace.monitor.id]

  rule_group_enabled = true

  rule {
    alert      = "ARO cluster ${azurerm_redhat_openshift_cluster.aro.name} is down for at least 1 hour "
    enabled    = true
    expression = <<EOF
up{cluster="${azurerm_redhat_openshift_cluster.aro.name}",apiserver="kube-apiserver",prometheus_replica=~".*-0"} == 0
EOF
    for        = "PT1H"
    severity   = 1 # Sev 0 - Critical, 1 - Error, 2 - Warning, 3 - Informational, 4 - Verbose

    action {
      action_group_id = data.azurerm_monitor_action_group.default.id
    }

    alert_resolution {
      auto_resolved   = true
      time_to_resolve = "PT15M"
    }
  }

  depends_on = [null_resource.cluster-config]
}
