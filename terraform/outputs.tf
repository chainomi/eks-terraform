output "aws_account_id" {
  description = "Account ID for environment"
  value = data.aws_caller_identity.current.id
}


output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks.kubeconfig
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.config_map_aws_auth
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "oidc_arn" {
  description = "Kubernetes OIDC arn"
  value       =  module.eks.oidc_provider_arn
}

output "oidc_url" {
  description = "Kubernetes OIDC url"
  value       =  module.eks.cluster_oidc_issuer_url
}


# output "ecr_registry_id" {
#   description = "The account ID of the registry holding the repository."
#   value =  aws_ecr_repository.clusterRepo.registry_id
# }

# output "ecr_url" {
#   description = "ecr repository url"
#   value = aws_ecr_repository.clusterRepo.repository_url
# }

output "repository_arn_map" {
  value       = module.ecr.repository_arn_map
  description = "Repository id map"
}

output "repository_url_map" {
  value       = module.ecr.repository_url_map
  description = "Repository url map"
}