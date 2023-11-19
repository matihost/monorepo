resource "aws_vpc" "main" {
  cidr_block         = var.vpc_ip_cidr_range
  instance_tenancy   = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.prefix}-${var.region}"
  }
}


resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.prefix}-${var.region}-default"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-${var.region}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = var.zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_ip_cidr_range
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.prefix}-${var.region}-public-${each.key}"
    Tier = "public"
  }
}


resource "aws_security_group" "nat" {
  name        = "${local.prefix}-nat"
  description = "Defined traffic allowed on NAT instance"

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-nat"
  }

  ingress {
    description = "SSH from single external IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Terraform removed default egress ALLOW_ALL rule
  # It has to be explicitely added
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# setup NAT instance as NAT Gateway is not free-tier eliglible
resource "aws_instance" "nat" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.public[var.zone].id
  key_name               = aws_key_pair.vm_key.key_name
  vpc_security_group_ids = [aws_security_group.nat.id]
  # NAT instance has to have source / dest adress check disabled
  source_dest_check = false

  user_data = templatefile("${path.module}/nat.init.tpl.sh", {
    private_cidr = aws_vpc.main.cidr_block,
    }
  )

  tags = {
    Name = "${local.prefix}-${var.region}-nat"
  }

  depends_on = [ aws_default_route_table.main ]
}


resource "aws_subnet" "private" {
  for_each = var.zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.private_ip_cidr_range
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags = {
    Name = "${local.prefix}-${var.region}-private-${each.key}"
    Tier = "private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.zones
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  # default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = {
    Name = "${local.prefix}-${var.region}-nat"
  }
}


resource "aws_security_group" "http_from_single_computer" {
  name        = "${local.prefix}-http-from-single-external-ip-only"
  description = "Allow HTTP access only from single computer"

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-http-from-single-external-ip-only"
  }

  ingress {
    description = "HTTP from laptop only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.external_access_ip}/32"]
  }

  ingress {
    description = "HTTPS from laptop only"
    from_port   = 443
    to_port     = 443
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

output "nat_id" {
  value = aws_instance.nat.id
}

output "nat_ip" {
  value = aws_instance.nat.public_ip
}

output "nat_dns" {
  value = aws_instance.nat.public_dns
}

output "nat_ssh" {
  description = "Connect to NAT instance"
  value       = format("ssh -i ~/.ssh/id_rsa.aws.vm ubuntu@%s", aws_instance.nat.public_dns)
}
