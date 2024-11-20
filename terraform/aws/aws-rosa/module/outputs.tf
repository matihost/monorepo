output "cluster_api_url" {
  value       = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.api_url
  description = "The URL of the API server."
}

output "cluster_console_url" {
  value       = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.console_url
  description = "The URL of the console."
}

output "cluster_domain" {
  value       = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.domain
  description = "The DNS domain of cluster."
}

output "cluster_current_version" {
  value       = rhcs_cluster_rosa_hcp.rosa_hcp_cluster.current_version
  description = "The currently running version of OpenShift on the cluster."
}
