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
  key_name   = "vm"
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


resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.private_access.id]
  iam_instance_profile   = var.instance_profile
  # to use cloud-init and bash script
  # use https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
  user_data = templatefile("ec2.cloud-init.tpl", {
    ssh_key = filebase64("~/.ssh/id_rsa.aws.vm"),
    ssh_pub = filebase64("~/.ssh/id_rsa.aws.vm.pub"),
    }
  )
  tags = {
    Name = "vm-${random_id.instance_id.hex}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Ubuntu AMI has ubuntu user name instead of ec2-user
    private_key = file("~/.ssh/id_rsa.aws.vm")
    host        = self.public_ip
  }

  # demonstrate provisioner usage
  # use user_data and script or cloud-init config instead
  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install mlocate",
    ]
  }
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

output "ec2_user_data" {
  description = "Instance user_data (aka init config)"
  value       = format("aws ec2 describe-instance-attribute --instance-id %s --attribute userData --output text --query \"UserData.Value\" | base64 --decode", aws_instance.vm.id)
}
