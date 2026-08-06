data "azuread_client_config" "current" {
}

data "azuread_service_principal" "graph" {
  display_name = "Microsoft Graph"
}

resource "azuread_application" "idp_app" {
  count = var.oidc_app != null ? 1 : 0

  display_name     = "${var.env}-${var.oidc_app.display_name_suffix}"
  sign_in_audience = "AzureADMyOrg"

  group_membership_claims = [
    "SecurityGroup"
  ]

  owners = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = var.oidc_app != null ? var.oidc_app.redirect_uris : []

    implicit_grant {
      id_token_issuance_enabled = true
    }
  }

  required_resource_access {
    resource_app_id = data.azuread_service_principal.graph.client_id


    resource_access {
      id   = data.azuread_service_principal.graph.oauth2_permission_scope_ids["User.Read"]
      type = "Scope"
    }

    resource_access {
      id   = data.azuread_service_principal.graph.oauth2_permission_scope_ids["email"]
      type = "Scope"
    }
  }

  optional_claims {
    id_token {
      name = "preferred_username"
    }

    id_token {
      name = "email"
    }

    id_token {
      name = "groups"

      additional_properties = [
        "cloud_displayname"
      ]
    }
  }
}


resource "azuread_service_principal" "sp" {
  count = var.oidc_app != null ? 1 : 0

  client_id = azuread_application.idp_app[0].client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "exp" {
  rotation_days = 90
}

resource "azuread_application_password" "client_secret" {
  count = var.oidc_app != null ? 1 : 0

  application_id = azuread_application.idp_app[0].id
  rotate_when_changed = {
    rotation = time_rotating.exp.id
  }
}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "oidc_client_id" {
  value = azuread_application.idp_app[0].client_id
}

output "oidc_client_secret" {
  value     = var.oidc_app != null ? azuread_application_password.client_secret[0].value : "N/A"
  sensitive = true
}

output "oidc_issuer_url" {
  value = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
}
