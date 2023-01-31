output "sa-okd-installer-key" {
  value     = google_secret_manager_secret_version.okd-installer-secret-value.secret_data
  sensitive = true
}
