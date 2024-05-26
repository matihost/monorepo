locals {
  # tflint-ignore: terraform_unused_declarations
  private_subnet_ids = [for subnet in data.aws_subnet.private : subnet.id]
}

data "aws_vpc" "vpc" {
  tags = {
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
