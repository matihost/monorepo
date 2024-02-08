locals{
  subnet_ids =  [for subnet in data.ibm_is_subnet.subnet: subnet.id]
}

data "ibm_is_ssh_key" "key" {
  name = var.ssh_key_id
}

# to get id of image you want run:
# ibmcloud is images |grep -v obsolete | grep -v deprecated |grep ubuntu
data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-22-04-3-minimal-amd64-2"
}


data "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

data "ibm_is_subnet" "subnet" {
  for_each = var.subnetworks

  vpc  = data.ibm_is_vpc.vpc.id
  name = each.value.name
}

data "ibm_is_security_group" "private" {
  name = var.private_security_group_name
}

data "ibm_is_security_group" "public-lb" {
  name = var.public_lb_security_group_name
}


resource "ibm_is_placement_group" "group" {
  resource_group = var.resource_group_id

  strategy = "host_spread"
  name     = "${local.prefix}-placement-group"
}

resource "ibm_is_instance_template" "webserver" {
  resource_group = var.resource_group_id

  name    = "${local.prefix}-template"
  image   =  data.ibm_is_image.ubuntu.id
  profile =  var.instance_profile

  metadata_service {
    enabled = true
    protocol = "https"
  }

  # zone and subnetwork are mandatory - even when ig will use different zones and subnetworks
  zone = var.zone
  primary_network_interface {
    name            = "eth0"
    subnet          = data.ibm_is_subnet.subnet[var.zone].id
    security_groups = [ data.ibm_is_security_group.private.id ]
  }

  vpc       = data.ibm_is_vpc.vpc.id
  keys      = [ data.ibm_is_ssh_key.key.id ]
  user_data = file("${path.module}/webserver.cloud-init.yaml")

  placement_group = ibm_is_placement_group.group.id

  # TODO trusted profile are not supported when instance template is used to sping instance group
  # default_trusted_profile_target = ibm_iam_trusted_profile.webserver.id
  # Attempt to create IG with default_trusted_profile_target set returns:
  # error 400:
  # "code": "service_error",
  # "message": "dry run instance internal error"
  #
  # changing:
  # default_trusted_profile_auto_link = false
  # but still keeping default_trusted_profile_target ends with:
  # error 500:
  # "code": "service_error",
  # "message": "dry run instance internal error"
}
