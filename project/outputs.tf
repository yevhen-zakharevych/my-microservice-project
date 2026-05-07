output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID створеної VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "jenkins_release" {
  description = "Jenkins Helm release name"
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  description = "Jenkins namespace"
  value = module.jenkins.jenkins_namespace
}

output "argocd_namespace" {
  value = module.argo_cd.namespace
}

output "argocd_server_hostname" {
  value = module.argo_cd.server_hostname
}

output "argocd_initial_admin_password" {
  value     = module.argo_cd.initial_admin_password
  sensitive = true
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "aurora_writer_endpoint" {
  value = module.rds.aurora_writer_endpoint
}

output "aurora_reader_endpoint" {
  value = module.rds.aurora_reader_endpoint
}

output "monitoring_namespace" {
  value = module.monitoring.namespace
}

output "grafana_admin_password" {
  value     = module.monitoring.grafana_admin_password
  sensitive = true
}

output "grafana_service_name" {
  value = module.monitoring.grafana_service_name
}