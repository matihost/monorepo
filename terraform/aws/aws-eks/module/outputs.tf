output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.prefix
}

output "region" {
  description = "AWS region"
  value       = var.region
}


output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}
