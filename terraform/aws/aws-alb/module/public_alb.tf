locals {
  public_subnet_ids = [for subnet in data.aws_subnet.public : subnet.id]
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
  name               = local.prefix
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.public_lb_security_group.id]

  subnets = local.public_subnet_ids

  # Unable to use subnet mapping as ALB does not support EIP
  # They are managed by AWS and use AWS-owned public IPs, not Elastic IPs from your account.
  # The ALB is fronted by AWS's internal scaling infrastructure, which dynamically allocates IPs from an AWS pool.
  # Alternatives to inability to set fixed IP for ALB:
  #
  # Use a static DNS name
  #     ALBs come with a DNS name like:
  #     my-alb-1234567890.us-east-1.elb.amazonaws.com
  #     You can create a CNAME (e.g. app.example.com) that points to this.
  #     This is the recommended approach - no need for static IPs in most cases.
  # Use AWS Global Accelerator
  #     If you really need fixed IP addresses for an ALB:
  #         Create an AWS Global Accelerator
  #         Point the accelerator to your ALB as an endpoint.
  #         You`ll get two static IPs (one per edge location) that front the ALB
  #     Supported for ALB, NLB, EC2, and more.
  # Use NLB + ALB combo (advanced pattern)
  #     Use a Network Load Balancer with EIPs
  #     Route traffic from the NLB to ALB behind it (via TCP forwarding)
  #     This is complex and often overkill unless you're tightly constrained by firewall or IP whitelisting needs
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
  name     = local.prefix
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  target_type = "instance" # ALB supports instance, ip, lambda

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
