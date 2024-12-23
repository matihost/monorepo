locals {
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
}


data "aws_vpc" "vpc" {
  default = var.vpc_name == "default" ? true : null

  tags = var.vpc_name == "default" ? null : {
    Name = var.vpc_name
  }
}

data "aws_subnet" "private" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = each.key
  tags = {
    Tier = "private"
  }
}
resource "aws_efs_file_system" "fs" {
  tags = {
    Name = local.prefix
  }

  encrypted = "true"


  performance_mode = "generalPurpose"

  protection {
    replication_overwrite = "ENABLED"
  }

  provisioned_throughput_in_mibps = "0"


  throughput_mode = "bursting"
}


resource "aws_security_group" "nfs" {
  name        = "${local.prefix}-nfs"
  description = "Allow EFS access from internal VPC only"

  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix}-nfs"
  }

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
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



resource "aws_efs_mount_target" "mount_target" {
  for_each = toset(local.private_subnet_ids)

  file_system_id  = aws_efs_file_system.fs.id
  security_groups = [aws_security_group.nfs.id]
  subnet_id       = each.key
}
