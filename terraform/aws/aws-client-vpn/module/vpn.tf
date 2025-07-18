data "aws_vpc" "vpc" {
  default = var.vpc == "default" ? true : null

  tags = var.vpc == "default" ? null : {
    Name = var.vpc
  }
}

locals {
  association_subnet_ids = toset([for subnet in data.aws_subnet.association-subnet : subnet.id])
}


# The subnets to associate Client VPN for HA
data "aws_subnet" "association-subnet" {
  for_each          = var.zones
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = each.key
  tags = var.subnet == "default" ? null : {
    Tier = var.subnet
  }
}

# The subnet used to be used for Internet traffic routing
data "aws_subnet" "routing-subnet" {
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = var.zone
  tags = var.subnet == "default" ? null : {
    Tier = var.subnet
  }
}


# All Subnets from vpc

data "aws_subnets" "subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_subnet" "subnet" {
  for_each = toset(data.aws_subnets.subnet.ids)
  id       = each.value
}


resource "aws_ec2_client_vpn_endpoint" "main" {
  client_cidr_block  = var.client_cidr_block
  description        = local.prefix
  security_group_ids = compact(concat([aws_security_group.main.id], var.security_group_ids))
  # self_service_portal    = var.self_service_portal
  server_certificate_arn = aws_acm_certificate.server.arn
  dns_servers            = var.dns_servers
  session_timeout_hours  = 24
  split_tunnel           = var.split_tunnel
  vpc_id                 = data.aws_vpc.vpc.id

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client.arn
  }


  client_login_banner_options {
    banner_text = "Connecting to ${local.prefix} Client VPN"
    enabled     = true
  }

  connection_log_options {
    cloudwatch_log_group  = aws_cloudwatch_log_group.main.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.main.name
    enabled               = true
  }
}

# Create association to each private subnet
# Associaction creates automatically a route entry to entire VPC via associated subnet
resource "aws_ec2_client_vpn_network_association" "main" {
  for_each = local.association_subnet_ids

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = each.key
}

# # Create routing to all subnets in VPC
# resource "aws_ec2_client_vpn_route" "subnet" {
#   for_each = { for subnet in data.aws_subnet.subnet : subnet.id => subnet }

#   client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
#   destination_cidr_block = each.value.cidr_block
#   description            = "Route to subnet ${each.value.id}"
#   target_vpc_subnet_id   = each.key

#   depends_on = [aws_ec2_client_vpn_network_association.main]
# }

# Route traffic to Internet via routing-subnet
resource "aws_ec2_client_vpn_route" "internet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = "0.0.0.0/0"
  description            = "Internet access route"
  target_vpc_subnet_id   = data.aws_subnet.routing-subnet.id

  depends_on = [aws_ec2_client_vpn_network_association.main]
}

# Authorize all Client VPN client to access VPC CIDR range
resource "aws_ec2_client_vpn_authorization_rule" "vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = data.aws_vpc.vpc.cidr_block
  authorize_all_groups   = true
  description            = "Authorization rule to access VPC"
}

# Authorize all Client VPN client to access Internet
resource "aws_ec2_client_vpn_authorization_rule" "internet" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
  description            = "Authorization rule to access Internet"
}

# Security group to apply on Client VPN endpoint itself
resource "aws_security_group" "main" {
  name        = "${var.name}-security-group"
  description = "Control traffic to the VPN client"
  vpc_id      = data.aws_vpc.vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr_block] # VPN client CIDR
    description = "Allow SSH from VPN clients"
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr_block] # VPN client CIDR
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr_block] # VPN client CIDR
  }

  # Allow all outbound traffic to VPC
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  # Allow all outbound traffic to Internet
  egress {
    description = "Rule to allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_cloudwatch_log_group" "main" {
  name              = local.cloudwatch_log_group
  retention_in_days = 14
}

resource "aws_cloudwatch_log_stream" "main" {
  name           = "client"
  log_group_name = aws_cloudwatch_log_group.main.name
}


output "client_vpn_endpoint_id" {
  value = aws_ec2_client_vpn_endpoint.main.id
}

output "region" {
  value = var.region
}
