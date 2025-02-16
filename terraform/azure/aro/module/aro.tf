data "azurerm_subnet" "main-subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.master_subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}

data "azurerm_subnet" "worker-subnet" {
  name                 = "${data.azurerm_virtual_network.vnet.name}-${var.worker_subnet_suffix}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}


resource "azurerm_redhat_openshift_cluster" "aro" {
  name                = local.cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name

  cluster_profile {
    # when domain contains "." character for example: dev.weu.shared1.company.com
    # then console url is:
    # https://console-openshift-console.apps.dev.weu.shared1.company.com
    # and DNS records needs to be setup:
    # https://learn.microsoft.com/en-us/azure/openshift/create-cluster?tabs=azure-cli#prepare-a-custom-domain-for-your-cluster-optional
    # otherwise the console url is then:
    # https://console-openshift-console.apps.devshared1.northeurope.aroapp.io
    domain = "${var.env}${var.cluster_name}"

    # Available varsions:
    # az aro get-versions --location northeurope
    # Useful only during initial creation - as cluster can be created on with some version and later upgrade changes the version
    version = "4.15.35"


    # Resource Group Name: "dev"
    # Open Shift Cluster Name: "dev-weu-shared1"): performing CreateOrUpdate:
    # unexpected status 400 (400 Bad Request) with error: InvalidParameter: The
    # provided resource group
    # '/subscriptions/..../resourceGroups/dev' is
    # invalid: must be different from resourceGroup of the OpenShift cluster
    # object.
    #
    managed_resource_group_name = "aro-${local.cluster_name}"

    pull_secret = var.rh_pull_secret
  }

  network_profile {
    pod_cidr     = "10.128.0.0/14"
    service_cidr = "172.30.0.0/16"
  }

  main_profile {
    # az vm list-skus --location northeurope --size Standard_D --all --output table
    vm_size   = "Standard_D8s_v5"
    subnet_id = data.azurerm_subnet.main-subnet.id
  }

  api_server_profile {
    visibility = "Public"
  }

  ingress_profile {
    visibility = "Public"
  }

  worker_profile {
    # az vm list-skus --location northeurope --size Standard_D --all --output table
    vm_size      = "Standard_D4s_v5"
    disk_size_gb = 128
    # The maximum number of worker nodes definable at creation time is 50.
    # Maxi is 250 nodes after the cluster is created.
    node_count = 3
    subnet_id  = data.azurerm_subnet.worker-subnet.id
  }

  service_principal {
    client_id     = azuread_application.aro.client_id
    client_secret = azuread_service_principal_password.aro.value
  }

  depends_on = [
    azurerm_role_assignment.role_network1,
    azurerm_role_assignment.role_network2,
  ]

  lifecycle {
    ignore_changes = [
      # change in version as result in update forces recretion
      cluster_profile[0].version,
      # nodes are managed via MachineSet objects after cluster creation
      main_profile[0].vm_size,
      worker_profile[0].node_count,
      worker_profile[0].vm_size
    ]
  }
}


resource "null_resource" "cluster-config" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/configure-cluster.sh '${azurerm_redhat_openshift_cluster.aro.resource_group_name}' '${azurerm_redhat_openshift_cluster.aro.name}' '${azurerm_redhat_openshift_cluster.aro.api_server_profile[0].url}' '${var.region}' '${jsonencode(var.oidc)}' '${jsonencode(var.namespaces)}'"
  }

  depends_on = [
    azurerm_redhat_openshift_cluster.aro,
  ]
}

output "cluster_name" {
  value = azurerm_redhat_openshift_cluster.aro.name
}

output "cluster_rg" {
  value = azurerm_redhat_openshift_cluster.aro.resource_group_name
}

output "console_url" {
  value = azurerm_redhat_openshift_cluster.aro.console_url
}


output "api_url" {
  value = azurerm_redhat_openshift_cluster.aro.api_server_profile[0].url
}

output "api_ip" {
  value = azurerm_redhat_openshift_cluster.aro.api_server_profile[0].ip_address
}


output "ingress_name" {
  value = azurerm_redhat_openshift_cluster.aro.ingress_profile[0].name
}

output "ingress_ip" {
  value = azurerm_redhat_openshift_cluster.aro.ingress_profile[0].ip_address
}
