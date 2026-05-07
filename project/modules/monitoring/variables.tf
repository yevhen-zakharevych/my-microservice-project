variable "cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate of the EKS cluster"
  type = string
}

variable "namespace" {
  description = "The Kubernetes namespace for monitoring resources"
  type    = string
  default = "monitoring"
}

variable "grafana_admin_password" {
  description = "The admin password for Grafana"
  type      = string
  sensitive = true
}

variable "chart_version" {
  type    = string
  default = "58.7.1"
}