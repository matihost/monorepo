resource "aws_vpc" "main" {
  cidr_block       = var.vpc_ip_cidr_range
  instance_tenancy = "default"

  # In order to associate with Route53 private hosted zone
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.prefix}"
  }
}


resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "${local.prefix}-default"
  }
}

resource "aws_route" "main-igw" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each                = var.zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.public_ip_cidr_range
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${local.prefix}-public-${each.key}"
    Tier                     = "public"
    "kubernetes.io/role/elb" = 1
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
    description = "SSH from single external access IP range only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_access_range]
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

  ingress {
    description = "OTEL from VPC"
    from_port   = 4317
    to_port     = 4318
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

  egress {
    description = "OTEL traffic"
    from_port   = 4317
    to_port     = 4318
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
    Name = "${local.prefix}-nat"
  }

  depends_on = [aws_default_route_table.main]
}


resource "aws_subnet" "private" {
  for_each                = var.zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.private_ip_cidr_range
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags = {
    Name                              = "${local.prefix}-private-${each.key}"
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table_association" "private" {
  for_each       = var.zones
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  # default route, mapping the VPC's CIDR block to "local", is created implicitly and cannot be specified.

  tags = {
    Name = "${local.prefix}-nat"
  }
}

resource "aws_route" "nat-nat" {
  route_table_id         = aws_route_table.nat.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

resource "aws_security_group" "http_from_external_range" {
  name        = "${local.prefix}-http-from-external-access-range"
  description = "Allow HTTP access only external IP access range"

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-http-from-external-access-range"
  }

  ingress {
    description = "HTTP from laptop only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_access_range]
  }

  ingress {
    description = "HTTPS from laptop only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.external_access_range]
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


resource "aws_security_group" "internal" {
  name        = "${local.prefix}-internal"
  description = "Allow internal traffic"

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-internal"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
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
