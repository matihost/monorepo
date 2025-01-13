resource "keycloak_realm" "id" {
  realm   = var.realm_name
  enabled = true

  account_theme = "keycloak.v3"
  admin_theme   = "keycloak.v2"
  # TODO add attributes, like tags
  # attributes                               = {}
  display_name_html        = "ID"
  duplicate_emails_allowed = false
  edit_username_allowed    = false
  email_theme              = "keycloak"
  login_theme              = "keycloak.v2"
  login_with_email_allowed = true
  # TODO add password policy
  # password_policy                          = null
  refresh_token_max_reuse        = 0
  registration_email_as_username = true
  remember_me                    = true

  ssl_required = "external"

  user_managed_access = true

  # TODO productionalization
  # reset_password_allowed                   = false
  # verify_email                             = false
  # registration_allowed                     = false
}
