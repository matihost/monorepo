
resource "ibm_is_network_acl" "default" {
  name = "${local.prefix}-${var.region}-default-acl"
  vpc = ibm_is_vpc.main.id

  rules {
      name        = "allow-all-ingress"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "inbound"
  }
  rules {
      name        = "allow-all-egress"
      action      = "allow"
      source      = "0.0.0.0/0"
      destination = "0.0.0.0/0"
      direction   = "outbound"
  }
}

resource "ibm_is_vpc" "main" {
  name = "${local.prefix}-${var.region}"
}


resource "ibm_is_subnet" "subnet" {
  for_each = var.zones
  name            = "${local.prefix}-${var.region}-subnet-${each.key}"
  vpc             = ibm_is_vpc.main.id
  zone            = each.key
  public_gateway  = ibm_is_public_gateway.pubgw[each.key].id

  ipv4_cidr_block = each.value.ip_cidr_range


  # provisioner "local-exec" {
  #   command = "sleep 300"
  #   when    = "destroy"
  # }
}

resource "ibm_is_public_gateway" "pubgw" {
  for_each = var.zones
  name = "${local.prefix}-${each.key}-pubgw"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
}




resource "ibm_is_security_group" "bastion" {
    name = "${ibm_is_vpc.main.name}-bastion"
    vpc  = ibm_is_vpc.main.id
}

resource "ibm_is_security_group_rule" "bastion_ingress_ssh_all" {
    group     = ibm_is_security_group.bastion.id
    direction = "inbound"
    remote    = "0.0.0.0/0"

    tcp {
      port_min = 22
      port_max = 22
    }
}


resource "ibm_is_security_group_rule" "bastion_ingress_http_all" {
    group     = ibm_is_security_group.bastion.id
    direction = "inbound"
    remote    = "0.0.0.0/0"

    tcp {
      port_min = 80
      port_max = 80
    }
}


resource "ibm_is_security_group_rule" "bastion_egress_all" {
    group     = ibm_is_security_group.bastion.id
    direction = "outbound"
    remote    = "0.0.0.0/0"
}
