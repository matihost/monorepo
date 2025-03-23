output "keycloak_glb_public_ip" {
  value = google_compute_global_forwarding_rule.keycloak.ip_address
}
output "keycloak_initial_admin_username" {
  value     = google_sql_user.user.name
  sensitive = true
}

output "keycloak_initial_admin_password" {
  value     = random_string.pass.result
  sensitive = true
}

output "db_connection_name" {
  value = google_sql_database_instance.keycloak.connection_name
}

output "keycloak_gs_bucket" {
  value = google_storage_bucket.keycloak.name
}
