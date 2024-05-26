locals {
  webserver_zones = var.create_sample_instance ? var.zones : {}
}

resource "aws_instance" "webserver" {
  for_each = local.webserver_zones

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.private[each.key].id
  # Terraform ignores associate_public_ip_address = false when subnet_id is not provided
  # and chosen subnet assigns Public Ips (aka map_public_ip_on_launch = true on aws_subnet)
  associate_public_ip_address = false
  key_name                    = aws_key_pair.vm_key.key_name
  vpc_security_group_ids      = [aws_security_group.internal_access.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm-ec2.name
  user_data                   = file("${path.module}/private_webserver.cloud-init.yaml")
  tags = {
    Name = "${local.prefix}-${each.key}-webserver"
  }

  # ensure private only EC2 is started after NAT instance is attached to private subnet
  depends_on = [aws_route_table_association.private]
}



output "webserver_id" {
  value = var.create_sample_instance ? aws_instance.webserver[var.zone].id : "N/A"
}

output "webserver_ip" {
  value = var.create_sample_instance ? aws_instance.webserver[var.zone].private_ip : "N/A"
}


output "connect_via_bastion_proxy" {
  description = "Assuming bastion_proxy is exposed locally, connects to websever"
  value       = var.create_sample_instance ? format("http_proxy=localhost:8888 curl http://%s", aws_instance.webserver[var.zone].private_ip) : "N/A"
}
