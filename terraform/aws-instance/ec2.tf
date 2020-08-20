provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


resource "random_id" "instance_id" {
  byte_length = 8
}

resource "aws_security_group" "private_access" {
  name        = "private_access"
  description = "Allow HTTP access from single computer and opens SSH"

  tags = {
    Name = "private_access"
  }

  ingress {
    description = "HTTP from laptop"
    from_port   = 80
    to_port     = 80
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
  tags = {
    Name = "vm-${random_id.instance_id.hex}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu" # Ubuntu AMI has ubuntu user name instead of ec2-user
    private_key = file("~/.ssh/id_rsa.aws.vm")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y install nginx",
      "sudo systemctl enable --now nginx"
    ]
  }
}

variable "external_access_ip" {
  type        = string
  description = "The public IP which is allowed to access instance"
}
