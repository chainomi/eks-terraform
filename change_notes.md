#changes from main branch required to use eks cluster with existing vpc


replace contents of vpc.tf
new module added

add folder networking
this is a new module that builds subnets, route tables, gateways (internet and nat) and an eip

tfvars - add vpc_id, public and private cidr parameters
vpc_id = "xxx-xxxxxxxx"
public_subnets_cidrs = ["XX.XX.XX.XX", "XX.XX.XX.XX", "XX.XX.XX.XX"]
private_subnets_cidrs = ["XX.XX.XX.XX", "XX.XX.XX.XX", "XX.XX.XX.XX"]

variables.tf - add vpc_id to variables
variable "vpc_id" {
  description = "vpc id of existing vpc"
}

variable "public_subnets_cidrs" {
  description = "cidrs for public subnets"
}

variable "private_subnets_cidrs" {
  description = "cidrs for private subnets"
}


eks-cluster.tf
subnets      = module.vpc.private_subnets
vpc_id          = var.vpc_id

security-groups.tf - change vpc_id value to var.vpc_id

vpc_id      = var.vpc_id

#new additions
added policy for session manager to node role in eks-cluster.tf
