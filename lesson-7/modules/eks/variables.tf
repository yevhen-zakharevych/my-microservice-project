variable "subnet_ids" {
  description = "Subnets for EKS cluster and node group"
  type        = list(string)
}