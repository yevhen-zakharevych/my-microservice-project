## Project Structure

The project is divided into Terraform infrastructure provisioning and Kubernetes deployment charts:

- `backend.tf`: Configures the Terraform backend for state management.
- `main.tf`: Main configuration file that instantiates all modules.
- `outputs.tf`: Defines the outputs of the Terraform configuration (e.g., ECR URL, EKS cluster name).
- `modules/`: Directory containing reusable Terraform modules.
  - `s3-backend/`: S3 bucket and DynamoDB for remote state locking.
  - `vpc/`: Virtual Private Cloud (VPC), subnets, route tables, and security groups.
  - `ecr/`: Amazon Elastic Container Registry (ECR) for storing Docker images.
  - `eks/`: Amazon Elastic Kubernetes Service (EKS) cluster and managed node groups.
  - `jenkins/`: Jenkins deployment on EKS using Helm.
  - `argo_cd/`: Argo CD deployment on EKS using Helm.
  - `rds/`: Relational Database Service (RDS) and Aurora cluster management.
  - `monitoring/`: Prometheus and Grafana stack for observability.
- `django/`: The Django application source code, Dockerfile, and Jenkinsfile.
- `charts/`: Directory containing Helm charts for application deployment.
  - `django-app/`: Helm chart for the Django application (includes Deployment, Service, ConfigMap, and HPA).

## 🗄️ RDS Module

This module provides a flexible way to deploy either a standard AWS RDS instance or an Amazon Aurora cluster.

### Usage Example

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false # Set to true for Aurora

  # Standard RDS Settings
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Aurora Settings (used if use_aurora = true)
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count          = 1

  # Common Configuration
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "myapp"
  username                = "postgres"
  password                = "admin123AWS23"
  vpc_id                  = module.vpc.vpc_id
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = true
  multi_az                = false
  backup_retention_period = 1

  parameters = {
    max_connections = "200"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Input Variables

| Name | Description | Type |
| :--- | :--- | :--- |
| `name` | The name prefix for RDS resources. | `string` |
| `use_aurora` | Toggle between Standard RDS (`false`) and Aurora Cluster (`true`). | `bool` |
| `engine` | Database engine for Standard RDS (e.g., `postgres`, `mysql`). | `string` |
| `engine_version` | Engine version for Standard RDS. | `string` |
| `engine_cluster` | Engine for Aurora (e.g., `aurora-postgresql`, `aurora-mysql`). | `string` |
| `engine_version_cluster` | Engine version for Aurora. | `string` |
| `instance_class` | The compute and memory capacity of the DB instance. | `string` |
| `allocated_storage` | Storage capacity in GB (only for Standard RDS). | `number` |
| `db_name` | Name of the database to create on startup. | `string` |
| `username` | Master username for the database. | `string` |
| `password` | Master password for the database. | `string` |
| `vpc_id` | ID of the VPC where the DB will be deployed. | `string` |
| `subnet_private_ids` | Private subnets for the DB subnet group. | `list(string)` |
| `subnet_public_ids` | Public subnets for the DB subnet group. | `list(string)` |
| `publicly_accessible` | Whether the DB is accessible from outside the VPC. | `bool` |
| `multi_az` | Whether to create a standby instance in a different AZ. | `bool` |
| `backup_retention_period` | Number of days to retain automated backups. | `number` |
| `parameters` | Map of custom DB parameters. | `map(string)` |

### Configuration Guide

#### Switching between Standard RDS and Aurora
- Use the `use_aurora` variable. 
- **Note:** Standard RDS supports `db.t3.micro` (Free Tier), while Aurora typically requires `db.t3.medium` or higher.

#### Changing the DB Engine
- For Standard RDS: Update `engine`, `engine_version`, and `parameter_group_family_rds`.
- For Aurora: Update `engine_cluster`, `engine_version_cluster`, and `parameter_group_family_aurora`.

#### Scaling Instance Class
- Modify the `instance_class` variable. For example, change from `db.t3.micro` to `db.t3.medium` for better performance.

## 🚀 Deployment Guide

### Step 1: Infrastructure Provisioning (Terraform)

Initialize and apply the Terraform configurations to create the AWS resources:

```bash
terraform init
terraform plan
terraform apply
```

### Step 2: Configure Kubernetes Access

Update your local kubeconfig to interact with the new EKS cluster:

```bash
aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
```

### Step 3: Build and Push Docker Image

Build the Docker image for the required architecture (e.g., linux/amd64) and push it to the newly created ECR repository:

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-ecr-url>
docker build --platform linux/amd64 -t django-app:latest .
docker tag django-app:latest <your-ecr-url>/django-app:v1
docker push <your-ecr-url>/django-app:v1
```

### Step 4: Deploy the Application (Helm)

Update the image.repository and image.tag in charts/django-app/values.yaml, then deploy the release:

```bash
helm upgrade --install django-release ./charts/django-app
```

Check the status of your pods and get the LoadBalancer URL to access the application:

```bash
kubectl get pods
kubectl get svc django-release-django-app
```

## 🤖 Automated CI/CD & GitOps Guide

This project features a fully automated CI/CD pipeline using Jenkins and Argo CD.

### 🔍 How to Verify Jenkins Jobs

1.  **Access Jenkins:**
    *   Retrieve the LoadBalancer URL:
        ```bash
        kubectl get svc -n jenkins jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
        ```
    *   **Login:** `admin` / **Password:** `admin123` (as configured in JCasC).
2.  **Seed Job:**
    *   Upon your first login, locate and run the `seed-job`.
    *   This job will automatically generate the main pipeline: `goit-django-docker`.
3.  **Monitor the Pipeline:**
    *   Open the `goit-django-docker` job and select the latest build.
    *   Click on **Console Output** to see the real-time logs.
    *   **Verification:** You will see **Kaniko** building the Docker image, pushing it to **Amazon ECR**, and finally a **git push** confirmation indicating that the `values.yaml` in your Git repository has been updated with the new image tag.

### 🐙 How to Monitor Results in Argo CD

1.  **Access Argo CD:**
    *   Retrieve the LoadBalancer URL:
        ```bash
        kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
        ```
    *   **Login:** `admin`
    *   **Get Initial Password:**
        ```bash
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
        ```
2.  **Application Dashboard:**
    *   In the Argo CD UI, you will see the `django-app` application.
    *   Click on the application card to see the live resource tree (Deployment, Pods, Services, HPA).
3.  **GitOps Synchronization:**
    *   Argo CD monitors your Git repository for changes.
    *   As soon as Jenkins pushes the updated `values.yaml`, Argo CD will detect that the cluster is **Out of Sync**.
    *   Depending on the sync policy, it will automatically pull the new configuration and update your application in the EKS cluster. You can watch the Pods being cycled to the new image version in real-time.

## 📊 Monitoring & Observability

The infrastructure includes a comprehensive monitoring stack based on **Prometheus** and **Grafana** (deployed via the `kube-prometheus-stack`).

### 🔍 How to Access Grafana

1.  **Get the Service Name:**
    ```bash
    kubectl get svc -n monitoring
    ```
2.  **Port Forward to Local Machine:**
    ```bash
    kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
    ```

### 📈 What's Included?
- **Prometheus:** Collects metrics from your Django application, EKS nodes, and Kubernetes system components.
- **Grafana:** Pre-configured with dashboards for:
    - Kubernetes Cluster Health
    - Node Exporter (CPU, Memory, Disk, Network)
    - Pod-level resource usage
- **Alertmanager:** Configured to handle alerts based on Prometheus metrics.

### 💡 Troubleshooting Resource Issues
The monitoring stack requires significant resources. If pods are stuck in `Pending`:
1.  **Check Pod Status:** `kubectl get pods -n monitoring`
2.  **Check for Errors:** `kubectl describe pod <pod-name> -n monitoring`
3.  **Scale Up:** If you see "Insufficient memory" or "Too many pods", ensure your EKS Node Group uses at least `t3.medium` instances and has an appropriate `desired_size`.

## Cleanup
To avoid incurring future AWS charges, destroy all created resources.
Important: You must uninstall the Helm release before destroying the Terraform infrastructure to ensure cloud LoadBalancers are properly removed.

```bash
helm uninstall django-release
terraform destroy
```
