output "namespace" {
  description = "The namespace where the monitoring resources are deployed"
  value = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_service_name" {
  description = "The name of the Grafana service"
  value = "grafana"
}

output "prometheus_service_name" {
  description = "The name of the Prometheus service"
  value = "kube-prometheus-stack-prometheus"
}

output "grafana_admin_password" {
  description = "The admin password for Grafana"
  value       = var.grafana_admin_password
  sensitive   = true
}