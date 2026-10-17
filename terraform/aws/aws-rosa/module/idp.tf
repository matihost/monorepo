resource "rhcs_identity_provider" "idp" {
  count = var.openid != null ? 1 : 0

  cluster        = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  name           = var.openid.idp_name
  mapping_method = "claim"

  openid = {
    issuer        = var.openid.issuer_url
    client_id     = var.openid.client_id
    client_secret = var.openid.client_secret

    claims = {
      preferred_username = [var.openid.preferred_username_claim]
      name               = [var.openid.name_claim]
      email              = [var.openid.email_claim]
      groups             = [var.openid.groups_claim]
    }

    extra_scopes = var.openid.extra_scopes
  }
}

output "oidc_web_redirect_url" {
  value       = nonsensitive(var.openid) != null ? nonsensitive("https://oauth.${rhcs_cluster_rosa_hcp.rosa_hcp_cluster.domain}/oauth2callback/${var.openid.idp_name}") : "N/A"
  description = "Web Redirect URL for OIDC provider."
}
