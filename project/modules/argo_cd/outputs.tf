output "namespace" {
  description = "Argo CD namespace"
  value       = var.namespace
}

output "server_hostname" {
  description = "Argo CD server service hostname"
  value       = "argo-cd.${var.namespace}.svc.cluster.local"
}

output "initial_admin_password" {
  description = "Instruction to get initial admin password"
  value       = "Run: kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}
