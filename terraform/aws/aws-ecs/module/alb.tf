locals {
  apps_with_lb = {
    for k, v in var.apps : k => v
    if v.port != 0
  }

}
resource "aws_lb" "app" {
  for_each = local.apps_with_lb

  name               = "${local.prefix}-${each.key}"
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.app-security-group[each.key].id]

  # TODO replace with subnet mapping to reserver EIP
  subnets = local.private_subnet_ids
}

resource "aws_lb_listener" "app" {
  for_each = local.apps_with_lb

  load_balancer_arn = aws_lb.app[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  # TODO convert to TSL/SSL
  # port              = "443"
  # protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app[each.key].arn
  }
}

resource "aws_lb_target_group" "app" {
  for_each = local.apps_with_lb

  name        = "${local.prefix}-${each.key}"
  port        = each.value.port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "5"
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "4"
    unhealthy_threshold = "2"
  }
}
