# resource "aws_eks_pod_identity_association" "association" {
#   cluster_name = aws_eks_cluster.example.name
#   namespace = var.namespace
#   service_account = var.service_account_name
#   role_arn = aws_iam_role.example.arn
# }
