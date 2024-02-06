resource "ibm_is_lb" "private" {
  resource_group = var.resource_group_id

  name = "${local.prefix}-alb-private"

  subnets = local.subnet_ids
  type = "private"

  security_groups = [ data.ibm_is_security_group.webserver.id ]

  # dns   {
  #   instance_crn = "crn:v1:staging:public:dns-svcs:global:a/exxxxxxxxxxxxx-xxxxxxxxxxxxxxxxx:5xxxxxxx-xxxxx-xxxxxxxxxxxxxxx-xxxxxxxxxxxxxxx::"
  #   zone_id = "bxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
  # }

  # datapath logging for the ALB only
  # logging = true

  # route_mmode is supported only by private network load balancers
  # route_mode = true
}


resource "ibm_is_lb_listener" "frontend-listener" {
  lb       = ibm_is_lb.private.id
  protocol = "http"
  port     = 80
  default_pool = ibm_is_lb_pool.backend-pool.id

  connection_limit = 1000
  idle_connection_timeout = 120
}


resource "ibm_is_lb_pool" "backend-pool" {
  name                = "${local.prefix}-pool-web"
  lb                  = ibm_is_lb.private.id
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
