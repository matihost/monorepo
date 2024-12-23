output "efs_file_system_id" {
  description = "EFS FileSystem ID"
  value       = aws_efs_file_system.fs.id
}

output "efs_name" {
  description = "EFS Name"
  value       = aws_efs_file_system.fs.name
}

output "efs_security_group" {
  description = "Kubernetes Cluster Name"
  value       = local.prefix
}
