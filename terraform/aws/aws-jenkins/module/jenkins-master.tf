resource "aws_security_group" "jenkins_master" {
  name        = "${local.prefix}-master"
  description = "Allow HTTP access from single computer and opens SSH"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${local.prefix}-master"
  }

  ingress {
    description = "HTTP from laptop"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
  }
  ingress {
    description = "HTTP 8080 from laptop"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Terraform removed default egress ALLOW_ALL rule
  # It has to be explicitely added
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "jenkins_key" {
  key_name   = local.prefix
  public_key = var.ssh_pub_key
}


data "aws_ami" "master" {
  most_recent = true

  filter {
    name   = "name"
    values = ["jenkins-master-${var.ec2_architecture}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ec2_architecture]
  }

  owners = ["self"]
}

data "aws_ami" "agent" {
  most_recent = true

  filter {
    name   = "name"
    values = ["jenkins-java-agent-${var.ec2_architecture}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = [var.ec2_architecture]
  }

  owners = ["self"]
}


data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    ---
    repo_upgrade: critical
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/jenkins-master.ssh.sh.tpl", {
      ssh_key = base64encode(var.ssh_key),
      ssh_pub = base64encode(var.ssh_pub_key),
    })
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/jenkins-master.startup.sh.tpl", {
      jenkins_agent_ami              = data.aws_ami.agent.id,
      jenkins_name                   = local.prefix,
      jenkins_agent_security_group   = aws_security_group.jenkins_agent.name,
      jenkins_agent_subnets          = join(",", local.agent_subnet_ids)
      jenkins_agent_ec2_architecture = var.ec2_architecture
    })
  }

}

resource "aws_launch_template" "jenkins" {
  name_prefix            = "${local.prefix}-master-"
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins-master.name
  }

  image_id = data.aws_ami.master.id

  instance_type = var.ec2_instance_type

  key_name = aws_key_pair.jenkins_key.key_name

  vpc_security_group_ids = [aws_security_group.jenkins_master.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.prefix}-master"
    }
  }

  # base64 encoded init config
  user_data = data.template_cloudinit_config.config.rendered
}

resource "aws_autoscaling_group" "jenkins" {
  name = "${local.prefix}-master"
  launch_template {
    id      = aws_launch_template.jenkins.id
    version = "$Latest"
  }
  vpc_zone_identifier = local.master_subnet_ids

  max_size         = 1
  desired_capacity = 1
  min_size         = 0

  wait_for_capacity_timeout = "10m"
}


# to retrieve EC2 instance created by ASG
# When there is no instance, it will fail hence it is not recommended to prepare output from ASG
# AWS CLI equivalent:
# aws ec2 describe-instances --filters 'Name=tag:Name,Values=jenkins --output json --region us-east-1 | jq -r '.Reservations[].Instances[].PublicIpAddress'
# data "aws_instances" "jenkins" {
#   instance_tags = {
#     Name = "jenkins"
#   }
#   depends_on = [aws_autoscaling_group.jenkins]
# }

# output "ec2_ip" {
#   value = data.aws_instances.jenkins.public_ips[0]
# }

# output "ec2_ssh" {
#   description = "Connect to bastion to be able to connect to other private only servers"
#   value       = format("ssh -i ~/.ssh/id_rsa.aws.vm ubuntu@%s", data.aws_instances.jenkins.public_ips[0])
# }

# output "ec2_user_data" {
#   description = "Intance user_data (aka init config)"
#   value       = format("aws ec2 describe-instance-attribute --instance-id %s --attribute userData --output text --query \"UserData.Value\" | base64 --decode", data.aws_instances.jenkins.ids[0])
# }
