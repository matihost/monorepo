resource "aws_launch_template" "webserver" {
  name                   = "webserver"
  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile
  }

  image_id = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"

  key_name = "vm"

  vpc_security_group_ids = [data.aws_security_group.internal_access.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "webserver"
    }
  }

  user_data = filebase64("webserver.cloud-init.yaml")
}

resource "aws_lb_target_group" "webserver" {
  name     = "webserver"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}


resource "aws_autoscaling_group" "webserver" {
  name = "webserver"
  launch_template {
    id      = aws_launch_template.webserver.id
    version = "$Latest"
  }
  # Subnets where to place instances
  vpc_zone_identifier = [data.aws_subnet.private_subnet.id]

  # ALBs Target Groups to place instances
  target_group_arns     = [aws_lb_target_group.webserver.arn]
  max_size              = 2
  min_size              = 1
  wait_for_elb_capacity = 1

  health_check_type = "ELB"
  # The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service.
  health_check_grace_period = 300

  # maximum time for Terraform to wait for ASG reach
  wait_for_capacity_timeout = "10m"
}

resource "aws_autoscaling_policy" "webserver" {
  name                   = "webserver"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.webserver.name
}


# Exposes  public-facing ALB to EC2 instances that have private IP addresses only.
# It works by setting up ALB to public subnets in the same Availability Zones as the private subnets that are used by your private instances.
# Then associate these public subnets to the internet-facing load balancer.
# In the below example, public facing subnets from zone a and b are allowing to route traffic to target_group of instances in private zones a and b.
# (In this example there is only one private network in zone a, but ALB requires at least two public subnets)
#
# Details: https://aws.amazon.com/premiumsupport/knowledge-center/public-load-balancer-private-ec2/
resource "aws_lb" "webserver" {
  name               = "webserver"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.http_from_single_computer.id]
  subnets            = [data.aws_subnet.public_subnet_1.id, data.aws_subnet.public_subnet_2.id]
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


output "alb_dns" {
  value = aws_lb.webserver.dns_name
}

# The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)
output "alb_canonical_zone" {
  value = aws_lb.webserver.zone_id
}
