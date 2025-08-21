data "azurerm_subnet" "system-subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.system_subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "worker-subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.worker_subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}


data "azurerm_log_analytics_workspace" "log" {
  name                = "${local.prefix}-log"
  resource_group_name = local.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name

  # Azure requires that a new, non-existent Resource Group is used, as otherwise,
  # the provisioning of the Kubernetes Service will fail.
  node_resource_group = "aks-${local.cluster_name}"

  dns_prefix = var.cluster_name

  # Private cluster/access settings
  private_cluster_enabled = !var.public
  private_dns_zone_id     = azurerm_private_dns_zone.aks-private-zone.id
  # This flag controls whether Azure also creates a public DNS record (FQDN)
  # that resolves to the private IP of the API server.
  # Useful if you want a stable, globally resolvable DNS name but still keep the endpoint private.
  private_cluster_public_fqdn_enabled = true

  # TODO
  # api_server_access_profile {
  #   authorized_ip_ranges = ...
  # }

  sku_tier              = var.ha ? "Standard" : "Free"
  cost_analysis_enabled = var.ha

  # Enable RBAC based on Azure AD/EntraId
  # https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac
  local_account_disabled = true
  azure_active_directory_role_based_access_control {
    tenant_id              = local.tenant_id
    azure_rbac_enabled     = true
    admin_group_object_ids = [azuread_group.cluster-admin.object_id]
  }

  identity {
    type         = "UserAssigned" # or SystemAssigned
    identity_ids = [azurerm_user_assigned_identity.cluster-admin.id]
  }
  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.cluster-admin.client_id
    object_id                 = azurerm_user_assigned_identity.cluster-admin.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.cluster-admin.id
  }

  # https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/aks-upgrade-practices#cluster-upgrades
  # kubernetes_version = "1.32"
  automatic_upgrade_channel = "patch" # or none
  node_os_upgrade_channel   = "NodeImage"
  # TODO ?
  # maintenance_window_auto_upgrade  {
  #   frequency = "Weekly"
  #   interval = "1"
  # }


  default_node_pool {
    name            = "system"
    vm_size         = "Standard_D8alds_v6" # 8 vCPU 16 GiB RAM with Ephemeral OS support
    os_disk_size_gb = 110

    # Requires support for Ephemeral OS from VM
    # VM family with local temp SSD with sufficient cache or temp disk size to hold the OS image.
    os_disk_type = "Ephemeral"
    os_sku       = "Ubuntu"

    # Enabling this option will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint.
    # temporary_name_for_rotation must be specified when changing this property.
    only_critical_addons_enabled = true
    #  Specifies the name of the temporary node pool used to cycle the default node pool for VM resizing
    temporary_name_for_rotation = "temp"
    vnet_subnet_id              = data.azurerm_subnet.system-subnet.id
    zones                       = ["1", "2", "3"]
    auto_scaling_enabled        = true
    min_count                   = var.ha ? "3" : 1
    max_count                   = 9
    node_public_ip_enabled      = false

    upgrade_settings {
      max_surge = "1"
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
  }

  # TODO
  # key_management_service {
  #   key_vault_key_id = ...
  #   key_vault_network_access = ...
  # }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  # Addons

  # to enable Azure AD Workload Identity oidc_issuer_enabled
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Managed Gatekeeper
  azure_policy_enabled = true


  # Managed Prometheus
  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }

  oms_agent {
    log_analytics_workspace_id      = data.azurerm_log_analytics_workspace.log.id
    msi_auth_for_monitoring_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log.id
  }

  # TODO https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
  # ingress_application_gateway {
  #   gateway_id = ...
  # }

  # open_service_mesh is Azure competition to Istio
  open_service_mesh_enabled = false
  # service_mesh_profile {
  #   mode = "Istio"
  #   revisions = ["asm-1-26"]
  #   internal_ingress_gateway_enabled = true
  #   external_ingress_gateway_enabled = var.public
  # }


  depends_on = [
    # to ensure to delete cluster then private dns zone and identity
    azurerm_role_assignment.aks-private-zone-admin,
  ]

  lifecycle {
    ignore_changes = [
      # At this time there's a bug in the AKS API where Tags for a Node Pool are not stored in the correct case
      # You may wish to use Terraform's ignore_changes functionality to ignore changes to the casing
      # until this is fixed in the AKS API.
      tags,
      default_node_pool[0].node_count,
    ]
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4ads_v6" # 4 vCPU 16 GiB RAM with Ephemeral OS support
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = 0.5 # note: this is the "maximum" price
  node_labels = {
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
  vnet_subnet_id  = data.azurerm_subnet.worker-subnet.id
  os_disk_size_gb = 110
  os_disk_type    = "Ephemeral"
  os_sku          = "Ubuntu"
  # Specifies the name of the temporary node pool used to cycle the node pool for VM resizing
  temporary_name_for_rotation = "temp"
  zones                       = ["1", "2", "3"]
  auto_scaling_enabled        = true
  min_count                   = 0
  max_count                   = 9
  node_public_ip_enabled      = false
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "worker"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D8alds_v6" # 8 vCPU 16 GiB RAM with Ephemeral OS support
  vnet_subnet_id        = data.azurerm_subnet.worker-subnet.id

  os_disk_size_gb = 110
  os_disk_type    = "Ephemeral"
  os_sku          = "Ubuntu"
  # Specifies the name of the temporary node pool used to cycle the node pool for VM resizing
  temporary_name_for_rotation = "temp"
  zones                       = ["1", "2", "3"]
  auto_scaling_enabled        = true
  min_count                   = var.ha ? "3" : 1
  max_count                   = 9
  node_public_ip_enabled      = false

  lifecycle {
    ignore_changes = [
      upgrade_settings[0].drain_timeout_in_minutes,
      upgrade_settings[0].max_surge,
      upgrade_settings[0].node_soak_duration_in_minutes,
    ]
  }
}


# resource "null_resource" "cluster-config" {
#   triggers = {
#     always_run = timestamp()
#   }
#   provisioner "local-exec" {
#     command = "${path.module}/configure-cluster.sh '${azurerm_kubernetes_cluster.aks.resource_group_name}' '${azurerm_kubernetes_cluster.aks.name}' '${var.region}' '${jsonencode(var.namespaces)}'"
#   }

#   depends_on = [
#     azurerm_kubernetes_cluster_node_pool.user,
#   ]
# }

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_rg" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}
