resource "aws_eks_identity_provider_config" "oidc" {
  count = var.oidc != null ? 1 : 0

  cluster_name = aws_eks_cluster.cluster.name

  oidc {
    client_id                     = var.oidc.client_id
    identity_provider_config_name = "${local.prefix}-oidc"
    issuer_url                    = var.oidc.issuer_url
    groups_claim                  = var.oidc.groups_claim
    username_claim                = var.oidc.username_claim
  }
}
