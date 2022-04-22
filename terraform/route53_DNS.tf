# This module updates the Route 53 record for the ingress domain with the proper alb dns address 

module "external_dns_poc" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-external-dns.git"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id
  helm_chart_version               = "6.2.4"

 settings = {
    "policy" = "sync" # Modify how DNS records are sychronized between sources and providers.
    "txtOwnerId" = "${var.environment}-${var.application_name}-domain" #unique identifier for each external DNS instance
  }
 
}
# Helm chart repo - https://artifacthub.io/packages/helm/bitnami/external-dns
# Module repo - https://github.com/DNXLabs/terraform-aws-eks-external-dns