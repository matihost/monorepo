resource "keycloak_group" "cluster-admins" {
  realm_id = keycloak_realm.id.id
  name     = "cluster-admins"
}



resource "random_password" "initial_password" {
  for_each = { for user in var.keycloak_users : user.email => user }

  keepers = {
    id = "initial"
  }

  length  = 10
  special = false
  upper   = true
  lower   = true
  numeric = true
}


resource "keycloak_user" "user" {
  for_each = { for user in var.keycloak_users : user.email => user }

  realm_id = keycloak_realm.id.id
  username = each.value.email
  enabled  = true

  email      = each.value.email
  first_name = each.value.name
  last_name  = each.value.surname

  email_verified = true

  initial_password {
    value     = random_password.initial_password[each.key].result
    temporary = true
  }
}


resource "keycloak_user_groups" "user_groups_association" {
  for_each = { for user in var.keycloak_users : user.email => user }

  realm_id   = keycloak_realm.id.id
  user_id    = keycloak_user.user[each.key].id
  exhaustive = false

  group_ids = [
    keycloak_group.cluster-admins.id
  ]
}

output "initial_users_passwords" {
  value     = { for email, password in random_password.initial_password : email => password.result }
  sensitive = true
}
