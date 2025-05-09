## Originator part
data "aws_vpc" "peer" {
  for_each = toset(var.vpc_peering_regions)

  provider = aws.by_region[each.key]

  filter {
    name   = "tag:Name"
    values = ["${var.env}-${each.key}"]
  }
}


# WARNING:
# Upon deletion the peering connection is marked as deleted and the removed after 2 hours
# Making logic with peering connections hard to test.
# Deleted: An active VPC peering connection has been deleted by either of the VPC owners,
# or a pending-acceptance VPC peering connection request has been deleted by the owner of the requester VPC.
# While in this state, the VPC peering connection cannot be accepted or rejected.
# The VPC peering connection remains visible to the party that deleted it for 2 hours,
# and visible to the other party for 2 days.
# If the VPC peering connection was created within the same AWS account,
# the deleted request remains visible for 2 hours.
resource "aws_vpc_peering_connection" "peer" {
  for_each = toset(var.vpc_peering_regions)

  vpc_id = aws_vpc.main.id

  peer_vpc_id   = data.aws_vpc.peer[each.key].id
  peer_owner_id = local.account_id
  peer_region   = each.key
  auto_accept   = false

  tags = {
    Side = "Requester"
    Name = "${local.prefix}2${data.aws_vpc.peer[each.key].tags["Name"]}"
  }
}

resource "aws_vpc_peering_connection_options" "requester" {
  for_each = var.finish_peering ? toset(var.vpc_peering_regions) : []

  # As options can't be set until the connection has been accepted
  # create an explicit dependency on the accepter.
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[each.key].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}


resource "aws_route" "originator-nat" {
  for_each = var.finish_peering ? toset(var.vpc_peering_regions) : []

  route_table_id            = aws_route_table.nat.id
  destination_cidr_block    = data.aws_vpc.peer[each.key].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[each.key].id
}

resource "aws_route" "originator-default" {
  for_each = var.finish_peering ? toset(var.vpc_peering_regions) : []

  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = data.aws_vpc.peer[each.key].cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[each.key].id
}



## Acceptance part
data "aws_vpc" "originator" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  provider = aws.by_region[each.key]

  filter {
    name   = "tag:Name"
    values = ["${var.env}-${each.key}"]
  }
}


# When recreate within 2h the error might appear,
# as connection peering created on acceptor side from requestor, is indistinguishable from Deleted ones
#
# Error: multiple EC2 VPC Peering Connections matched;
# use additional constraints to reduce matches to a single EC2 VPC Peering Connection
data "aws_vpc_peering_connection" "pc" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  vpc_id = data.aws_vpc.originator[each.key].id
}


resource "aws_vpc_peering_connection_accepter" "peer" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc[each.key].id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}


resource "aws_vpc_peering_connection_options" "peer" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc[each.key].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}


resource "aws_route" "peer-nat" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  route_table_id            = aws_route_table.nat.id
  destination_cidr_block    = data.aws_vpc_peering_connection.pc[each.key].cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc[each.key].id

  depends_on = [
    aws_vpc_peering_connection_accepter.peer
  ]
}

resource "aws_route" "peer-default" {
  for_each = toset(var.vpc_peering_acceptance_regions)

  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = data.aws_vpc_peering_connection.pc[each.key].cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc[each.key].id

  depends_on = [
    aws_vpc_peering_connection_accepter.peer
  ]
}
