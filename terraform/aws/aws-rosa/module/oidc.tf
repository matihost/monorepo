resource "rhcs_rosa_oidc_config" "oidc_config" {
  managed = true

  # TODO add option for unmanaged oidc
  # installer_role_arn = local.installer_role_arn
  # issuer_url = ...
  # secret_arn = ...

  # depends_on = [ aws_iam_role.account_role ]
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = "https://${rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url}"

  client_id_list = [
    "openshift",
    "sts.amazonaws.com"
  ]

  thumbprint_list = [rhcs_rosa_oidc_config.oidc_config.thumbprint]
}
