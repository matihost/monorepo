locals{
  public_subnet_ids =  [for subnet in data.aws_subnet.public: subnet.id]
}

data "aws_security_group" "public_lb_security_group" {
  tags = {
    Name = var.public_lb_security_group_name
  }
}

# Exposes  public-facing ALB to EC2 instances that have private IP addresses only.
# It works by setting up ALB to public subnets in the same Availability Zones as the private subnets that are used by your private instances.
# Then associate these public subnets to the internet-facing load balancer.
# In the below example, public facing subnets from zone a and b are allowing to route traffic to target_group of instances in private zones a and b.
# (In this example there is only one private network in zone a, but ALB requires at least two public subnets)
#
# Details: https://aws.amazon.com/premiumsupport/knowledge-center/public-load-balancer-private-ec2/
resource "aws_lb" "webserver" {
  name = local.prefix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.public_lb_security_group.id]

  # TODO replace with subnet mapping to reserver EIP
  subnets            = local.public_subnet_ids
}

resource "aws_lb_listener" "webserver" {
  load_balancer_arn = aws_lb.webserver.arn
  port              = "80"
  protocol          = "HTTP"

  # TODO convert to TSL/SSL
  # port              = "443"
  # protocol          = "HTTPS"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver.arn
  }
}

resource "aws_lb_target_group" "webserver" {
  name = local.prefix
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

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


output "public_alb_dns" {
  value = aws_lb.webserver.dns_name
}

# The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)
output "public_alb_canonical_zone" {
  value = aws_lb.webserver.zone_id
}
