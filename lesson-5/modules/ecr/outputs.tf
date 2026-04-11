output "repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.this.repository_url
}

output "scan_on_push" {
  description = "Whether image scanning on push is enabled for the ECR repository"
  value       = var.scan_on_push
}
