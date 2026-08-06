resource "rhcs_identity_provider" "idp" {
  count = var.openid != null ? 1 : 0

  cluster        = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.id
  name           = var.idp.idp_name
  mapping_method = "claim"

  openid = {
    issuer        = var.idp.issuer_url
    client_id     = var.idp.client_id
    client_secret = var.idp.client_secret

    claims = {
      preferred_username = [var.idp.preferred_username_claim]
      name               = [var.idp.name_claim]
      email              = [var.idp.email_claim]
      groups             = [var.idp.groups_claim]
    }

    extra_scopes = var.idp.extra_scopes
  }
}

output "oidc_web_redirect_url" {
  value       = nonsensitive(var.idp) != null ? nonsensitive("https://oauth.${rhcs_cluster_rosa_hcp.rosa_hcp_cluster.domain}/oauth2callback/${var.idp.idp_name}") : "N/A"
  description = "Web Redirect URL for OIDC provider."
}
