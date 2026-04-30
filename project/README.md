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
  - `argocd/`: Argo CD deployment on EKS using Helm.
- `charts/`: Directory containing Helm charts for application deployment.
  - `django-app/`: Helm chart for the Django application (includes Deployment, Service, ConfigMap, and HPA).

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

## Cleanup
To avoid incurring future AWS charges, destroy all created resources.
Important: You must uninstall the Helm release before destroying the Terraform infrastructure to ensure cloud LoadBalancers are properly removed.

```bash
helm uninstall django-release
terraform destroy
```
