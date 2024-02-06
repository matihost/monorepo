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

data "ibm_is_security_group" "webserver" {
  name = var.security_group_name
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
    security_groups = [ data.ibm_is_security_group.webserver.id ]
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


resource "ibm_is_instance_group" "ig" {
  resource_group = var.resource_group_id

  name              = "${local.prefix}-group"
  instance_template = ibm_is_instance_template.webserver.id
  instance_count    = 3
  subnets           = local.subnet_ids


  # If the membership count of an instance group is set to 0,
  # you can change the load balancer pool that is associated with the instance group.
  # You can select a different load balancer that is available, or select none to stop using an assigned load balancer.
  application_port = 80
  load_balancer = ibm_is_lb.private.id
  load_balancer_pool =  element(split("/", ibm_is_lb_pool.backend-pool.id), 1)


  lifecycle {
    ignore_changes = [
      instance_count,
    ]
  }
}

resource "ibm_is_instance_group_manager" "igm" {
  name               = "${local.prefix}-igm"
  aggregation_window = 120
  instance_group     = ibm_is_instance_group.ig.id
  #cooldown to be in the range (120 - 3600)
  cooldown             = 120
  manager_type         = "autoscale"
  enable_manager       = true
  max_membership_count = 6

  # Increasing min number ends with error:
  #
  # You cannot set the minimum number of instances to more than the current number of running instances,
  # or the maximum number to less than the current number of running instances.
  # To force a change to the way the instance group scales, you must first disable auto scale.
  # Then, adjust the membership count manually. Finally, adjust the minimum and maximum count if needed.
  min_membership_count = 1
}

resource "ibm_is_instance_group_manager_policy" "target-cpu" {
  name                   = "${local.prefix}-igm-policy"
  instance_group         = ibm_is_instance_group.ig.id
  instance_group_manager = ibm_is_instance_group_manager.igm.manager_id
  metric_type            = "cpu"
  metric_value           = 70
  policy_type            = "target"
}


# resource "ibm_is_instance_group_manager" "scheduler" {
#   name           = "${local.prefix}-scheduler"
#   instance_group = ibm_is_instance_group.ig.id
#   manager_type   = "scheduled"
#   enable_manager = true
# }

# # When AutoScale manager is active, membership count cannot be modified. Please disable AutoScale manager.",
# resource "ibm_is_instance_group_manager_action" "scheduler-action-down" {
#   name                   = "${local.prefix}-scheduler-down"
#   instance_group         = ibm_is_instance_group.ig.id
#   instance_group_manager = ibm_is_instance_group_manager.scheduler.manager_id
#   target_manager         = ibm_is_instance_group_manager.igm.manager_id
#   cron_spec              = "05 17 * * *"
#   min_membership_count   = 1
#   max_membership_count   = 6
# }

# resource "ibm_is_instance_group_manager_action" "scheduler-action-up" {
#   name                   = "${local.prefix}-scheduler-down"
#   instance_group         = ibm_is_instance_group.ig.id
#   instance_group_manager = ibm_is_instance_group_manager.scheduler.manager_id
#   target_manager         = ibm_is_instance_group_manager.igm.manager_id
#   cron_spec              = "05 08 * * *"
#   min_membership_count   = 3
#   max_membership_count   = 6
# }
