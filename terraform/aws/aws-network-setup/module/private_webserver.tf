resource "random_id" "webserver_instance_id" {
  byte_length = 8
}

resource "aws_security_group" "internal_access" {
  name        = "internal_access"
  description = "Allow HTTP & SSH access from internal VPC only"

  tags = {
    Name = "internal_access"
  }

  ingress {
    description = "HTTP from default VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }
  ingress {
    description = "SSH from default VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
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


resource "aws_instance" "webserver" {
  count         = var.create_sample_instance ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.private_a.id
  # Terraform ignores associate_public_ip_address = false when subnet_id is not provided
  # and chosen subnet assigns Public Ips (aka map_public_ip_on_launch = true on aws_subnet)
  associate_public_ip_address = false
  key_name                    = aws_key_pair.vm_key.key_name
  vpc_security_group_ids      = [aws_security_group.internal_access.id]
  user_data                   = file("${path.module}/private_webserver.cloud-init.yaml")
  tags = {
    Name = "webserver-${random_id.webserver_instance_id.hex}"
  }
}


output "webserver_ip" {
  value = var.create_sample_instance ? aws_instance.webserver[0].private_ip : "N/A"
}


output "connect_via_bastion_proxy" {
  description = "Assuming bastion_proxy is exposed locally, connects to websever"
  value       = var.create_sample_instance ? format("http_proxy=localhost:8888 curl http://%s", aws_instance.webserver[0].private_ip) : "N/A"
}
