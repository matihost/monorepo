resource "azuread_application" "aro" {
  display_name = "${local.cluster_name}-aro"
  description  = "ARO cluster: ${local.cluster_name} in resource group: ${local.resource_group_name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "aro-rbac" {
  display_name   = "rbac"
  application_id = azuread_application.aro.id
}


resource "azuread_service_principal" "aro" {
  description = "ARO cluster: ${local.cluster_name} in resource group: ${local.resource_group_name}"
  client_id   = azuread_application.aro.client_id
  owners      = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "aro" {
  service_principal_id = azuread_service_principal.aro.id
}

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  client_id = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}

resource "azurerm_role_assignment" "role_network1" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.aro.object_id
}

resource "azurerm_role_assignment" "role_network2" {
  #  "The resource provider service principal does not have Network Contributor role on nat gateway '/subscriptions/..../resourceGroups/dev/providers/Microsoft.Network/natGateways/dev-neu-natgateway'
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
}
