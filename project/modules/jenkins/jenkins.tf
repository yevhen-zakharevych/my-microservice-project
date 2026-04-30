resource "aws_iam_role" "jenkins" {
  name = "jenkins-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" : "system:serviceaccount:jenkins:jenkins"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.jenkins.name
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  namespace        = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.7.20"
  create_namespace = true
  timeout          = 1200

  set {
    name  = "controller.image.repository"
    value = "jenkins/jenkins"
  }

  set {
    name  = "controller.image.tag"
    value = "2.492.1-jdk17"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.jenkins.arn
  }

  values = [
    file("${path.module}/values.yaml")
  ]
}
