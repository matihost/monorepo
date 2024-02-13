resource "ibm_is_lb" "public-nlb" {
  resource_group = local.resource_group_id

  name = "${local.prefix}-nlb-public"

  # The subnets must be in the same VPC.
  # The load balancer's availability will depend on the availability of the zones the specified subnets reside in.
  # The load balancer must be in the application family for updating subnets.
  #
  # Load balancers in the network family allow only one subnet to be specified.
  #
  # "code": "load_balancer_subnet_over_quota",
  # "message": "No more than 1 subnet(s) per load balancer",
  # "more_info": "https://cloud.ibm.com/docs/vpc?topic=vpc-rias-error-messagesload_balancer_subnet_over_quota",
  #
  # while the closest is : https://cloud.ibm.com/docs/vpc?topic=vpc-rias-error-messages#load-balancer-over-quota
  subnets = [ data.ibm_is_subnet.subnet[var.zone].id ]

  # "network-fixed" for NLB, empty for ALB
  profile = "network-fixed"

  type = "public"

  security_groups = [ data.ibm_is_security_group.public-lb.id ]

  # dns   {
  #   instance_crn = "crn:v1:staging:public:dns-svcs:global:a/exxxxxxxxxxxxx-xxxxxxxxxxxxxxxxx:5xxxxxxx-xxxxx-xxxxxxxxxxxxxxx-xxxxxxxxxxxxxxx::"
  #   zone_id = "bxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
  # }

  # datapath logging for the ALB only
  # logging = true

  # route_mmode is supported only by private network load balancers
  # route_mode = true
}


resource "ibm_is_lb_listener" "public-nlb-frontend-listener" {
  lb       = ibm_is_lb.public-nlb.id
  protocol = "tcp"
  port     = 80
  default_pool = ibm_is_lb_pool.public-nlb-backend-pool.id

  # error: Network load balancer does not support Connection Limit.
  # connection_limit = 1000
}


resource "ibm_is_lb_pool" "public-nlb-backend-pool" {
  name                = "${local.prefix}-public-nlb-pool-web"
  lb                  = ibm_is_lb.public-nlb.id
  algorithm           = "round_robin"
  protocol            = "tcp"
  health_delay        = 5
  health_retries      = 2
  health_timeout      = 2
  health_type         = "http"
  health_monitor_port = "80"

  # Network load balancer pool does not support Proxy Protocol
  # so even default is "disabled" it has to be ommited
  # proxy_protocol      = "disabled"

  session_persistence_type = "source_ip"
}

# Manage manually
#
# data "ibm_is_instances" "webserver" {
#   resource_group = local.resource_group_id
#   # vpc            = data.ibm_is_vpc.vpc.id
#   instance_group = ibm_is_instance_group.ig.id
# }

# locals{
#   instances = toset([for instance in data.ibm_is_instances.webserver.instances: instance.id])
# }

# resource "ibm_is_lb_pool_member" "member" {
#   for_each = local.instances

#   lb        = ibm_is_lb.public-nlb.id
#   pool      = element(split("/", ibm_is_lb_pool.backend-pool.id), 1)
#   port      = 8080
#   target_id = each.key
# }


# Instance group can be attached only to single LB
# also
# NLB works only in single zone
resource "ibm_is_instance_group" "public-nlb-zonal-ig" {
  resource_group = local.resource_group_id

  name              = "${local.prefix}-zonal-group-for-pub-nlb"
  instance_template = ibm_is_instance_template.public-nlb-webserver.id
  instance_count    = 2
  subnets           = [ data.ibm_is_subnet.subnet[var.zone].id ]


  # If the membership count of an instance group is set to 0,
  # you can change the load balancer pool that is associated with the instance group.
  # You can select a different load balancer that is available, or select none to stop using an assigned load balancer.
  application_port = 80
  load_balancer = ibm_is_lb.public-nlb.id
  load_balancer_pool =  element(split("/", ibm_is_lb_pool.public-nlb-backend-pool.id), 1)


  lifecycle {
    ignore_changes = [
      instance_count,
    ]
  }
}

resource "ibm_is_instance_group_manager" "public-nlb-zonal-igm" {
  name               = "${local.prefix}-zonal-igm-for-pub-nlb"
  aggregation_window = 120
  instance_group     = ibm_is_instance_group.public-nlb-zonal-ig.id
  #cooldown to be in the range (120 - 3600)
  cooldown             = 120
  manager_type         = "autoscale"
  enable_manager       = true
  max_membership_count = 3

  # Increasing min number ends with error:
  #
  # You cannot set the minimum number of instances to more than the current number of running instances,
  # or the maximum number to less than the current number of running instances.
  # To force a change to the way the instance group scales, you must first disable auto scale.
  # Then, adjust the membership count manually. Finally, adjust the minimum and maximum count if needed.
  min_membership_count = 2
}

resource "ibm_is_instance_group_manager_policy" "public-nlb-zonal-target-cpu" {
  name                   = "${local.prefix}-zonal-igm-policy-for-pub-nlb"
  instance_group         = ibm_is_instance_group.public-nlb-zonal-ig.id
  instance_group_manager = ibm_is_instance_group_manager.public-nlb-zonal-igm.manager_id
  metric_type            = "cpu"
  metric_value           = 70
  policy_type            = "target"
}



# NLB is pass though loadbalancer - so security group on instances has to be in sync with security group on NLB
# Also instance group cannot override security group on network_interface
# So to create IG for public NLB it also require to create decicated instance template as well.
resource "ibm_is_instance_template" "public-nlb-webserver" {
  resource_group = local.resource_group_id

  name    = "${local.prefix}-public-nlb-template"
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
    security_groups = [ data.ibm_is_security_group.public-lb.id ]
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
