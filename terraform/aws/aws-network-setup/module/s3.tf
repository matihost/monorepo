resource "aws_vpc_endpoint" "s3" {
  count = var.create_s3_endpoint ? 1 : 0

  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}


resource "aws_vpc_endpoint_route_table_association" "private" {
  count = var.create_s3_endpoint ? 1 : 0

  route_table_id  = aws_route_table.nat.id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}


# access to S3 from public network also using private endpoint
resource "aws_vpc_endpoint_route_table_association" "public" {
  count = var.create_s3_endpoint ? 1 : 0

  route_table_id  = aws_vpc.main.default_route_table_id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
