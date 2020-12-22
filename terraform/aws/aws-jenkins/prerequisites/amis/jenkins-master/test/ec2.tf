provider "aws" {
  region = "us-east-1"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "private_access" {
  name        = "private_access"
  description = "Allow HTTP access from single computer or VPC and opens SSH"

  tags = {
    Name = "private_access"
  }

  ingress {
    description = "HTTP from laptop or from within VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32", data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "HTTP 8080 from laptop or from within VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32", data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "SSH from anywhere"
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


resource "aws_key_pair" "vm_key" {
  key_name   = var.name
  public_key = file("~/.ssh/id_rsa.aws.vm.pub")
}


data "aws_ami" "image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.name}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}


resource "aws_instance" "vm" {
  ami                    = data.aws_ami.image.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.private_access.id]
  iam_instance_profile   = var.instance_profile

  tags = {
    Name = "${var.name}-${random_id.instance_id.hex}"
  }

}

variable "name" {
  type    = string
  default = "jenkins-master"
}

variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}

variable "instance_profile" {
  default     = ""
  type        = string
  description = "The name of instance_profile (dynamically provisioning access to role)"
}


output "ec2_ip" {
  value = aws_instance.vm.public_ip
}

output "ec2_dns" {
  value = aws_instance.vm.public_dns
}

output "ec2_private_dns" {
  value = aws_instance.vm.private_dns
}
