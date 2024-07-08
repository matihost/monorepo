locals {
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  # possible filter ids from sample image:
  # aws ec2 describe-images --region us-east-1 --image-ids ami-0fc5d935ebf8bc3bc
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-*/ubuntu-noble-24.04-*-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ec2_architecture]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "default" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "private" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  tags = {
    Tier = "private"
  }
}


data "aws_subnet" "public" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  tags = {
    Tier = "public"
  }
}


data "aws_security_group" "webserver" {
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = var.ec2_security_group_name
  }
}




resource "aws_launch_template" "webserver" {
  name_prefix            = "${local.prefix}-"
  update_default_version = true

  iam_instance_profile {
    name = var.ec2_instance_profile
  }

  image_id = data.aws_ami.ubuntu.id

  instance_type = var.ec2_instance_type

  key_name = var.ec2_ssh_key_id

  vpc_security_group_ids = [data.aws_security_group.webserver.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.prefix
    }
  }

  user_data = filebase64("${path.module}/webserver.cloud-init.yaml")
}


resource "aws_autoscaling_group" "webserver" {
  name = local.prefix
  launch_template {
    id      = aws_launch_template.webserver.id
    version = "$Latest"
  }
  # Subnets where to place instances
  vpc_zone_identifier = local.private_subnet_ids

  # how to spread between zones
  placement_group = aws_placement_group.webserver.id

  # ALBs Target Groups to place instances
  target_group_arns     = [aws_lb_target_group.webserver.arn, aws_lb_target_group.tcp-webserver.arn]
  max_size              = 5
  min_size              = 1
  wait_for_elb_capacity = 1

  health_check_type = "ELB"
  # The amount of time until EC2 Auto Scaling performs the first health check on new instances after they are put into service.
  health_check_grace_period = 20

  # maximum time for Terraform to wait for ASG reach
  wait_for_capacity_timeout = "10m"

  dynamic "tag" {
    for_each = try(var.aws_tags, map())
    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }
}

resource "aws_autoscaling_policy" "webserver" {
  name                   = local.prefix
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 20
  autoscaling_group_name = aws_autoscaling_group.webserver.name
}


resource "aws_placement_group" "webserver" {
  name            = local.prefix
  strategy        = "partition"
  partition_count = 3
}
