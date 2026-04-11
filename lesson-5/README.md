# Lesson: Terraform Infrastructure for Microservice Project

## Project Structure

This Terraform project sets up the infrastructure for a microservice application on AWS. The structure is organized as follows:

- `backend.tf`: Configures the Terraform backend for state management.
- `main.tf`: Main configuration file that instantiates the modules.
- `outputs.tf`: Defines the outputs of the Terraform configuration.
- `modules/`: Directory containing reusable Terraform modules.
  - `ecr/`: Module for Amazon Elastic Container Registry (ECR).
    - `erc.tf`: ECR repository configuration.
    - `outputs.tf`: Outputs for the ECR module.
    - `variables.tf`: Variables for the ECR module.
  - `s3-backend/`: Module for S3 backend and DynamoDB for state locking.
    - `dynamodb.tf`: DynamoDB table for state locking.
    - `outputs.tf`: Outputs for the S3 backend module.
    - `s3.tf`: S3 bucket configuration for state storage.
    - `variables.tf`: Variables for the S3 backend module.
  - `vpc/`: Module for Virtual Private Cloud (VPC) setup.
    - `outputs.tf`: Outputs for the VPC module.
    - `routes.tf`: Route table configurations.
    - `variables.tf`: Variables for the VPC module.
    - `vpc.tf`: VPC, subnets, and security groups configuration.

## Commands for Initialization and Launch

To manage the infrastructure, use the following Terraform commands:

- `terraform init`: Initialize the Terraform working directory.
- `terraform plan`: Generate and show an execution plan.
- `terraform apply`: Apply the changes required to reach the desired state.
- `terraform destroy`: Destroy the Terraform-managed infrastructure.

## Modules

### s3-backend

This module sets up an S3 bucket for storing Terraform state files remotely and a DynamoDB table for state locking to prevent concurrent modifications. This ensures safe and collaborative infrastructure management.

### vpc

This module creates a Virtual Private Cloud (VPC) with subnets, route tables, and security groups. It provides the network foundation for deploying resources in AWS, including public and private subnets for better security and organization.

### ecr

This module configures Amazon Elastic Container Registry (ECR) repositories for storing Docker images. It enables secure and scalable container image management, which is essential for microservice deployments.
