resource "aws_ecr_repository" "clusterRepo" {
  name                 = "app"
  
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    "environment" = var.environment
  }
}

# Retrieving AWS account ID for ECR push command
data "aws_caller_identity" "current" {}

