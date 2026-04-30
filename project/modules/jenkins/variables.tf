variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  type        = string
  description = "IAM OIDC provider ARN"
}

variable "oidc_provider_url" {
  type        = string
  description = "IAM OIDC provider URL"
}
