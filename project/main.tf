provider "aws" {
  region = "eu-west-3" # Регіон AWS
}

module "s3_backend" {
  source      = "./modules/s3-backend"                # path
  bucket_name = "terraform-state-bucket-001812-01001" # name of S3
  table_name  = "terraform-locks"                     # Name DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"                               # Шлях до модуля VPC
  vpc_cidr_block     = "10.0.0.0/16"                                 # CIDR блок для VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # Публічні підмережі
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] # Приватні підмережі
  availability_zones = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]    # Зони доступності
  vpc_name           = "lesson-7-vpc"                                # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-7-django-app"
}

# Підключаємо кластер EKS
module "eks" {
  source          = "./modules/eks"
  subnet_ids      = module.vpc.private_subnets
}

