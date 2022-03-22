module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = var.node_instance_type
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = var.desired_nodes
      asg_min_size                  = var.minimum_nodes
      asg_max_size                  = var.maximum_nodes
      
      #additional tags to enable cluster auto scaler on worker nodes
      tags = [{
        key                 = "k8s.io/cluster-autoscaler/enabled"
        value               = "true"
        propagate_at_launch = true
      },
      {
        key                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
        value               = "owned"
        propagate_at_launch = true
      }]
  
    }
  ]

# map iam roles to eks cluster role. RBAC is applied using k8s_cluster_roles.tf config file and kubernetes provider
  map_roles = [
    {
      rolearn = data.aws_iam_role.eks_read_ClusterRole.arn
      username = "reader"
      groups    = ["reader"]
    },
    {
      rolearn = data.aws_iam_role.eks_admin_ClusterRole.arn
      username = "admin"
      groups    = ["admin"]
    }
  ]


}


# Pulling data for kubernetes provider "kubernetes.tf"
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id
  helm_chart_version               = "1.4.0" #added to ugrade version of chart in the future
  #chart information https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
  
}

module "cluster_autoscaler" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-cluster-autoscaler.git"

  enabled = true

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id
  aws_region                       = var.region
  helm_chart_version               = "9.9.2" 
  #chart info https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler

}

# Monitoring and metrics

module "grafana_prometheus_monitoring" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-grafana-prometheus.git"

  enabled = true

}
# Readme - https://github.com/DNXLabs/terraform-aws-eks-grafana-prometheus


#metric server for Horizontal pod scaler (HPA)

resource "helm_release" "metrics_server" {
  name = "metrics-server"
  chart = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.8.2"

  
}