resource "aws_key_pair" "vm_key" {
  key_name   = "vm"
  public_key = var.ssh_pub_key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  # possible filter ids from sample image:
  # aws ec2 describe-images --region us-east-1 --image-ids ami-0fc5d935ebf8bc3bc
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*-server-*"]
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

resource "aws_security_group" "bastion_access" {
  name        = "bastion_access"
  description = "Allow SSH access only from single computer"

  tags = {
    Name = "bastion_access"
  }

  ingress {
    description = "SSH from laptop only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
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


resource "aws_instance" "bastion_vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  subnet_id              = data.aws_subnet.default.id
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_access.id]
  user_data = templatefile("${path.module}/bastion.cloud-init.tpl", {
    ssh_key = base64encode(var.ssh_key),
    ssh_pub = base64encode(var.ssh_pub_key),
    }
  )
  tags = {
    Name = "bastion"
  }
}

output "bastion_id" {
  value = aws_instance.bastion_vm.id
}

output "bastion_ip" {
  value = aws_instance.bastion_vm.public_ip
}

output "bastion_dns" {
  value = aws_instance.bastion_vm.public_dns
}

output "expose_bastion_proxy_locally" {
  description = "Exposes proxy on localhost:8888 which can be used to connect to private only servers, sample: HTTP_PROXY=localhost:8888 curl http://private_server"
  value       = format("ssh -o StrictHostKeyChecking=accept-new -f -N -i ~/.ssh/id_rsa.aws.vm ubuntu@%s -L 8888:127.0.0.1:8888", aws_instance.bastion_vm.public_dns)
}

output "bastion_ssh" {
  description = "Connect to bastion to be able to connect to other private only servers"
  value       = format("ssh -o StrictHostKeyChecking=accept-new -i ~/.ssh/id_rsa.aws.vm ubuntu@%s", aws_instance.bastion_vm.public_dns)
}
