output "ghost_glb_public_ip" {
  value = google_compute_global_forwarding_rule.ghost.ip_address
}
output "db_connection_name" {
  value = google_sql_database_instance.ghost.connection_name
}
