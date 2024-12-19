resource "aws_iam_role" "fargate" {
  name = "${local.prefix}-fargate"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fargate-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

resource "aws_eks_fargate_profile" "fargate" {
  count = anytrue([for namespace in var.namespaces : namespace.fargate]) ? "1" : "0"

  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "${local.prefix}-fargate"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = local.private_subnet_ids

  dynamic "selector" {
    for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.fargate }
    iterator = it

    content {
      namespace = it.key
    }
  }
}
