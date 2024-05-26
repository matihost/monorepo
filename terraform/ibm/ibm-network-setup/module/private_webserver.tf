locals {
  webserver_zones = var.create_sample_instance ? var.zones : {}
}

resource "ibm_is_instance" "webserver" {
  resource_group = local.resource_group_id

  for_each = local.webserver_zones

  name    = "${local.prefix}-${each.key}-webserver"
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_profile

  default_trusted_profile_target = ibm_iam_trusted_profile.bastion.id

  metadata_service {
    enabled  = true
    protocol = "https"
  }
  primary_network_interface {
    name            = "eth0"
    subnet          = ibm_is_subnet.subnet[each.key].id
    security_groups = [ibm_is_security_group.internal.id]
  }

  vpc  = ibm_is_vpc.main.id
  zone = each.key
  keys = [ibm_is_ssh_key.bastion.id]

  user_data = templatefile("${path.module}/private_webserver.cloud-init.yaml", {
    log_ingestion_key = ibm_resource_key.logs-key.credentials.ingestion_key,
    region            = var.region,
    }
  )
}



output "webserver_id" {
  value = var.create_sample_instance ? ibm_is_instance.webserver[var.zone].id : "N/A"
}

output "webserver_ip" {
  value = var.create_sample_instance ? ibm_is_instance.webserver[var.zone].primary_network_interface[0].primary_ip[0].address : "N/A"
}


output "connect_via_bastion_proxy" {
  description = "Assuming bastion_proxy is exposed locally, connects to websever"
  value       = var.create_sample_instance ? format("http_proxy=localhost:8888 curl http://%s", ibm_is_instance.webserver[var.zone].primary_network_interface[0].primary_ip[0].address) : "N/A"
}
