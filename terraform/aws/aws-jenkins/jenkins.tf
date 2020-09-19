provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "jenkins_access" {
  name        = "jenkins_access"
  description = "Allow HTTP access from single computer and opens SSH"

  tags = {
    Name = "jenkins_access"
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
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.aws.vm.pub")
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = file("jenkins.cloud-init.yaml")
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("jenkins-startup.sh")
  }

}

resource "aws_launch_template" "jenkins" {
  name_prefix            = "jenkins"
  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile
  }

  image_id = data.aws_ami.ubuntu.id

  instance_type = "t2.micro"

  key_name = aws_key_pair.jenkins_key.key_name

  vpc_security_group_ids = [aws_security_group.jenkins_access.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "jenkins"
    }
  }

  # base64 encoded init config
  user_data = data.template_cloudinit_config.config.rendered
}

resource "aws_autoscaling_group" "jenkins" {
  name = "jenkins"
  launch_template {
    id      = aws_launch_template.jenkins.id
    version = "$Latest"
  }
  availability_zones = ["us-east-1a"]

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


variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}

variable "instance_profile" {
  default     = ""
  type        = string
  description = "The name of instance_profile (dynamically provisioning access to role)"
}
