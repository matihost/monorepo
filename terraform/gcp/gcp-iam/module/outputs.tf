output "sa-editor-key" {
  value     = google_secret_manager_secret_version.editor-secret-value.secret_data
  sensitive = true
}
