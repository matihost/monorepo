# resource "aws_lb" "private-web" {
#   enable_deletion_protection       = "false"
#   internal                         = "true"
#   ip_address_type                  = "ipv4"
#   load_balancer_type               = "network"
#   # by default traffic for TLP LB stays in the zone,
#   # if there is not enough instance, traffic may not reach target
#   # switching to
#   enable_cross_zone_load_balancing = "true"
#   name                             = "${local.prefix}-private"
#   security_groups                  = [data.aws_security_group.webserver.id]

#   subnets = local.private_subnet_ids
# }

# resource "aws_lb_listener" "private-web" {
#   default_action {
#     target_group_arn = aws_lb_target_group.tcp-webserver.arn
#     type             = "forward"
#   }

#   load_balancer_arn = aws_lb.private-web.arn
#   port              = "80"
#   protocol          = "TCP"
# }


# resource "aws_lb_target_group" "tcp-webserver" {
#   connection_termination = "false"
#   deregistration_delay   = "30"

#   health_check {
#     enabled             = "true"
#     healthy_threshold   = "2"
#     interval            = "5"
#     matcher             = "200-399"
#     path                = "/"
#     port                = "traffic-port"
#     protocol            = "HTTP"
#     timeout             = "4"
#     unhealthy_threshold = "2"
#   }

#   ip_address_type                   = "ipv4"
#   name                              = "${local.prefix}-private"
#   port                              = "80"
#   preserve_client_ip                = "true"
#   protocol                          = "TCP"
#   proxy_protocol_v2                 = "false"

#   stickiness {
#     cookie_duration = "0"
#     enabled         = "false"
#     type            = "source_ip"
#   }

#   target_type = "instance"
#   vpc_id      = data.aws_vpc.default.id
# }




# output "private_lb_dns" {
#   value = aws_lb.private-web.dns_name
# }

# # The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)
# output "private_lb_canonical_zone" {
#   value = aws_lb.private-web.zone_id
# }
