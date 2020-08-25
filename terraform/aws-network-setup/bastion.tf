
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
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.default.id
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_access.id]
  user_data = templatefile("bastion.cloud-init.tpl", {
    ssh_key = filebase64("~/.ssh/id_rsa.aws.vm"),
    ssh_pub = filebase64("~/.ssh/id_rsa.aws.vm.pub"),
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
  value       = format("ssh -f -N -i ~/.ssh/id_rsa.aws.vm ubuntu@%s -L 8888:127.0.0.1:8888", aws_instance.bastion_vm.public_dns)
}

output "bastion_ssh" {
  description = "Connect to bastion to be able to connect to other private only servers"
  value       = format("ssh -i ~/.ssh/id_rsa.aws.vm ubuntu@%s", aws_instance.bastion_vm.public_dns)
}
