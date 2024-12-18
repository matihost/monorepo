resource "aws_eks_pod_identity_association" "association" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.pod_identity_role != null }

  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = each.key
  service_account = "app"
  role_arn        = data.aws_iam_role.association[each.key].arn
}


# EKS Pod Identity roles has to have the following trust policy:
# Example:
# resource "aws_iam_role" "s3all" {
#   name = "s3all"

#   assume_role_policy = <<-EOF
#   {
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "Service": "pods.eks.amazonaws.com"
#         },
#         "Action": [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#       }
#     ]
#   }
#   EOF
# }
data "aws_iam_role" "association" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.pod_identity_role != null }

  name = each.value.pod_identity_role
}
