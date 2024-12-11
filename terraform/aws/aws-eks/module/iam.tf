locals {
  admin_arn = var.cluster_admin_arn != null ? var.cluster_admin_arn : data.aws_iam_session_context.current.issuer_arn
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.cluster.id
  principal_arn = local.admin_arn
  # kubernetes_groups = ["group-1", "group-2"]
  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.cluster.id
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = local.admin_arn

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin,
  ]
}
