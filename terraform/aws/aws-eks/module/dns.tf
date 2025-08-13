#  Private zones require at least one VPC association at all times.
resource "aws_route53_zone" "cluster" {
  name = local.cluster_dns_zone

  # NOTE: The aws_route53_zone vpc argument accepts multiple configuration
  #       blocks. The below usage of the single vpc configuration, the
  #       lifecycle configuration, and the aws_route53_zone_association
  #       resource is for illustrative purposes (e.g., for a separate
  #       cross-account authorization process, which is not shown here).
  vpc {
    vpc_id = data.aws_vpc.vpc.id
  }

  force_destroy = true

  lifecycle {
    ignore_changes = [vpc]
  }
}

# resource "aws_route53_zone_association" "secondary" {
#   zone_id = aws_route53_zone.cluster.zone_id
#   vpc_id  = data.aws_vpc.secondary.id
# }

output "cluster_dns_zone" {
  value = aws_route53_zone.cluster.name
}

output "cluster_dns_hosted_zone_id" {
  value = aws_route53_zone.cluster.zone_id
}
