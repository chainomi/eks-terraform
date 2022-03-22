module "ecr" {
  source  = "cloudposse/ecr/aws"
  version = "0.33.0"

  image_names = var.service_list

  image_tag_mutability = "MUTABLE"
  scan_images_on_push = true

}


# Retrieving AWS account ID for ECR push command
data "aws_caller_identity" "current" {}