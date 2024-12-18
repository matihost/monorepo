
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${aws_eks_cluster.cluster.name}-eks-irsa" },
    var.aws_tags
  )
}


data "aws_iam_policy_document" "irsa_trust_policy" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.irsa_policy != null }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:${each.key}:app-irsa"]
    }
  }
}


resource "aws_iam_role" "irsa" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.irsa_policy != null }

  name               = "${local.prefix}-${each.key}-irsa"
  assume_role_policy = data.aws_iam_policy_document.irsa_trust_policy[each.key].json
}

# TODO make irsa_policy a list of policies to assing to a role
resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = { for namespace in var.namespaces : namespace.name => namespace if namespace.irsa_policy != null }

  policy_arn = each.value.irsa_policy
  role       = aws_iam_role.irsa[each.key].name
}
