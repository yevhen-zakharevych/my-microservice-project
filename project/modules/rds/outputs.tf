output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = var.use_aurora ? null : aws_db_instance.standard[0].endpoint
}

output "aurora_writer_endpoint" {
  description = "Aurora writer endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : null
}

output "aurora_reader_endpoint" {
  description = "Aurora reader endpoint"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.rds.id
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.default.name
}