
data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.environment}-${var.application_name}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}


resource "random_id" "random_id_prefix" {
  byte_length = 2
}



module "vpc" {
  source               = "./networking"
  region               = var.region
  environment          = var.environment
  application          = var.application_name
  vpc_id               = var.vpc_id
  public_subnets_cidr  = var.public_subnets_cidrs
  private_subnets_cidr = var.private_subnets_cidrs
  availability_zones   = data.aws_availability_zones.available.names

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

}
