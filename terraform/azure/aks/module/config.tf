resource "null_resource" "cluster-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/configure-cluster.sh '${azurerm_kubernetes_cluster.aks.resource_group_name}' '${local.subscription_name}' '${azurerm_kubernetes_cluster.aks.name}' '${var.region}' '${azurerm_container_registry.aks.name}' '${jsonencode(var.namespaces)}'"
  }

  depends_on = [
    azurerm_kubernetes_cluster_node_pool.user,
    azuread_group.ns-edit,
    azuread_group.ns-view
  ]
}


resource "azuread_group" "ns-edit" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }


  display_name     = "aks-${local.cluster_name}-ns-${each.key}-edit"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azuread_group" "ns-view" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace }

  display_name     = "aks-${local.cluster_name}-ns-${each.key}-view"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}


data "azurerm_key_vault" "key_vault" {
  name                = local.key_vault_name
  resource_group_name = local.resource_group_name
}
