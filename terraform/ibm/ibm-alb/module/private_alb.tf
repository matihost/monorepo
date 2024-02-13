resource "ibm_is_lb" "private-alb" {
  resource_group = var.resource_group_id

  name = "${local.prefix}-alb-private"

  subnets = local.subnet_ids
  type = "private"

  security_groups = [ data.ibm_is_security_group.private.id ]

  # dns   {
  #   instance_crn = "crn:v1:staging:public:dns-svcs:global:a/exxxxxxxxxxxxx-xxxxxxxxxxxxxxxxx:5xxxxxxx-xxxxx-xxxxxxxxxxxxxxx-xxxxxxxxxxxxxxx::"
  #   zone_id = "bxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
  # }

  # datapath logging for the ALB only
  # logging = true

  # route_mmode is supported only by private network load balancers
  # route_mode = true
}


resource "ibm_is_lb_listener" "private-alb-frontend-listener" {
  lb       = ibm_is_lb.private-alb.id
  protocol = "http"
  port     = 80
  default_pool = ibm_is_lb_pool.private-alb-backend-pool.id

  connection_limit = 1000
  idle_connection_timeout = 120
}


resource "ibm_is_lb_pool" "private-alb-backend-pool" {
  name                = "${local.prefix}-private-alb-pool-web"
  lb                  = ibm_is_lb.private-alb.id
  algorithm           = "round_robin"
  protocol            = "http"
  health_delay        = 5
  health_retries      = 2
  health_timeout      = 2
  health_type         = "http"
  health_monitor_port = "80"
  # https://cloud.ibm.com/docs/vpc?topic=vpc-advanced-traffic-management#proxy-protocol-enablement
  proxy_protocol      = "disabled"
  session_persistence_type = "source_ip"
}


resource "ibm_is_instance_group" "private-alb-ig" {
  resource_group = var.resource_group_id

  name              = "${local.prefix}-group-for-priv-alb"
  instance_template = ibm_is_instance_template.webserver.id
  instance_count    = 3
  subnets           = local.subnet_ids


  # If the membership count of an instance group is set to 0,
  # you can change the load balancer pool that is associated with the instance group.
  # You can select a different load balancer that is available, or select none to stop using an assigned load balancer.
  application_port = 80
  load_balancer = ibm_is_lb.private-alb.id
  load_balancer_pool =  element(split("/", ibm_is_lb_pool.private-alb-backend-pool.id), 1)


  lifecycle {
    ignore_changes = [
      instance_count,
    ]
  }
}

resource "ibm_is_instance_group_manager" "private-alb-igm" {
  name               = "${local.prefix}-igm-for-priv-alb"
  aggregation_window = 120
  instance_group     = ibm_is_instance_group.private-alb-ig.id
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

resource "ibm_is_instance_group_manager_policy" "private-alb-target-cpu" {
  name                   = "${local.prefix}-igm-policy-for-priv-alb"
  instance_group         = ibm_is_instance_group.private-alb-ig.id
  instance_group_manager = ibm_is_instance_group_manager.private-alb-igm.manager_id
  metric_type            = "cpu"
  metric_value           = 70
  policy_type            = "target"
}


resource "ibm_is_instance_group_manager" "priv-alb-scheduler" {
  name           = "${local.prefix}-scheduler-for-priv-alb"
  instance_group = ibm_is_instance_group.private-alb-ig.id
  manager_type   = "scheduled"
  enable_manager = true
}

# When AutoScale manager is active, membership count cannot be modified. Please disable AutoScale manager.",
resource "ibm_is_instance_group_manager_action" "priv-alb-scheduler-action-down" {
  name                   = "${local.prefix}-priv-alb-scheduler-down"
  instance_group         = ibm_is_instance_group.private-alb-ig.id
  instance_group_manager = ibm_is_instance_group_manager.priv-alb-scheduler.manager_id
  target_manager         = ibm_is_instance_group_manager.private-alb-igm.manager_id
  cron_spec              = "05 17 * * *"
  min_membership_count   = 1
  max_membership_count   = 6
}

resource "ibm_is_instance_group_manager_action" "priv-alb-scheduler-action-up" {
  name                   = "${local.prefix}-priv-alb-scheduler-down"
  instance_group         = ibm_is_instance_group.private-alb-ig.id
  instance_group_manager = ibm_is_instance_group_manager.priv-alb-scheduler.manager_id
  target_manager         = ibm_is_instance_group_manager.private-alb-igm.manager_id
  cron_spec              = "05 08 * * *"
  min_membership_count   = 3
  max_membership_count   = 6
}
