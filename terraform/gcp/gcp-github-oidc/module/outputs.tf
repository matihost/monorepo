output "gsa_name" {
  description = "GSA name"
  value       = google_service_account.gha.email
}

output "pool_name" {
  description = "Pool name"
  value       = google_iam_workload_identity_pool.pool.name
}

output "provider_name" {
  description = "Provider name"
  value       = google_iam_workload_identity_pool_provider.provider.name
}
