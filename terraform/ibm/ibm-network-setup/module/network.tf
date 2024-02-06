
resource "ibm_is_network_acl" "all" {
  resource_group = var.resource_group_id

  name = "${local.prefix}-${var.region}-all-acl"
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
  resource_group = var.resource_group_id

  name = "${local.prefix}-${var.region}"
  # by default it assumes zones subnets cidrs can be only in respectively
  # 10.243.0.0/18,  10.243.64.0/18,  10.243.128.0/18
  address_prefix_management = "manual"

  # VPC creates default ones with these names,
  # you cannot assign existing ones, b/c in order to create one VPC has to be created before
  default_security_group_name = "${local.prefix}-${var.region}-default-sg"
  default_network_acl_name = "${local.prefix}-${var.region}-default-acl"
  default_routing_table_name = "${local.prefix}-${var.region}-default-rt"
}


resource "ibm_is_vpc_address_prefix" "prefix" {
  for_each = var.zones
  cidr = each.value.ip_cidr_range
  name = "${local.prefix}-${each.key}-addrprefix"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
}


resource "ibm_is_subnet" "subnet" {
  resource_group = var.resource_group_id

  for_each = var.zones
  name            = "${local.prefix}-${each.key}-subnet"
  vpc             = ibm_is_vpc.main.id
  zone            = each.key
  public_gateway  = ibm_is_public_gateway.pubgw[each.key].id

  ipv4_cidr_block = each.value.ip_cidr_range

  depends_on = [
    ibm_is_vpc_address_prefix.prefix
  ]
}

resource "ibm_is_public_gateway" "pubgw" {
  resource_group = var.resource_group_id

  for_each = var.zones
  name = "${local.prefix}-${each.key}-pubgw"
  vpc  = ibm_is_vpc.main.id
  zone = each.key
}



# Bastion SG
resource "ibm_is_security_group" "bastion" {
    resource_group = var.resource_group_id

    name = "${ibm_is_vpc.main.name}-bastion"
    vpc  = ibm_is_vpc.main.id
}

resource "ibm_is_security_group_rule" "bastion_ingress_ssh_all" {
    group     = ibm_is_security_group.bastion.id
    direction = "inbound"

    # Remote - Describes the set of network interfaces to which this rule allows traffic (or from which, for outbound rules).
    # You can specify this value as either an IP address, a CIDR block, or all the identifiers of a single security group (ID, CRN, and name).
    # If this value is omitted, a CIDR block of 0.0.0.0/0 is used to allow traffic from any source
    # (or to any source, for outbound rules).
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


# Internal access only SG
resource "ibm_is_security_group" "internal" {
    resource_group = var.resource_group_id

    name = "${ibm_is_vpc.main.name}-internal-only"
    vpc  = ibm_is_vpc.main.id
}


resource "ibm_is_security_group_rule" "internal_ingress_ssh" {
    group     = ibm_is_security_group.internal.id
    direction = "inbound"
    remote    = "10.0.0.0/8"

    tcp {
      port_min = 22
      port_max = 22
    }
}


resource "ibm_is_security_group_rule" "internal_ingress_http" {
    group     = ibm_is_security_group.internal.id
    direction = "inbound"
    remote    = "10.0.0.0/8"

    tcp {
      port_min = 80
      port_max = 80
    }
}


resource "ibm_is_security_group_rule" "internal_egress_all" {
    group     = ibm_is_security_group.internal.id
    direction = "outbound"
    remote    = "0.0.0.0/0"
}
