resource "azurerm_network_interface" "lb-ip" {
  count = var.public ? 0 : 1

  name                = "${local.cluster_name}-nginx-ingress"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.system-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_public_ip" "lb-ip" {
  count = var.public ? 1 : 0

  name                = "${local.cluster_name}-nginx-ingress"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  nginx-ip = length(azurerm_public_ip.lb-ip) > 0 ? azurerm_public_ip.lb-ip[0].ip_address : azurerm_network_interface.lb-ip[0].private_ip_address
}

output "nginx-ip" {
  value = local.nginx-ip
}

resource "azurerm_private_dns_a_record" "lb" {
  name                = "*.svc"
  zone_name           = azurerm_private_dns_zone.aks-private-zone.name
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [local.nginx-ip]
}
