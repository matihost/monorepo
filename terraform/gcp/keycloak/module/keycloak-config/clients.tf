resource "keycloak_openid_client" "eks" {
  client_id = "eks"
  realm_id  = keycloak_realm.id.id
  name      = "eks"
  enabled   = true

  access_type               = "CONFIDENTIAL"
  client_authenticator_type = "client-secret"

  valid_redirect_uris = ["http://localhost:8000/*"]
  web_origins         = ["http://localhost:8000"]

  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = false
  frontchannel_logout_enabled  = true
  # frontchannel_logout_url                    = null

  #  Allow to include all roles mappings in the access token.
  full_scope_allowed = true
}


resource "keycloak_openid_group_membership_protocol_mapper" "eks_group_mapper" {
  add_to_access_token = true
  add_to_id_token     = true
  add_to_userinfo     = true
  claim_name          = "groups"
  client_id           = keycloak_openid_client.eks.id
  full_path           = false
  name                = "groups"
  realm_id            = keycloak_realm.id.id
}


output "eks_client_id_secret" {
  value     = keycloak_openid_client.eks.client_secret
  sensitive = true
}
