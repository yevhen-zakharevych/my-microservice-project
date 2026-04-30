output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "IAM OIDC provider URL"
  value       = aws_iam_openid_connect_provider.eks.url
}
