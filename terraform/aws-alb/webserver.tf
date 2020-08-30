

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


#TODO
