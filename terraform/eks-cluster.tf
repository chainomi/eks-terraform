module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.21"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true
  # cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id = module.vpc.vpc_id

  #IAM
  # workers_additional_policies = ["arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess"]
  cluster_iam_role_name = "eks-${var.application_name}-${var.environment}-cluster-role"
  workers_role_name = "eks-${var.application_name}-${var.environment}-worker-node-role"
  workers_additional_policies = ["${aws_iam_policy.additional_node_policy.arn}"]

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

 node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    "${var.managed_node_group_name}" = {
      name_prefix = "${local.cluster_name}-managed-node" 
      desired_capacity = var.managed_node_desired_capacity
      max_capacity     = var.managed_node_max_capacity
      min_capacity     = var.managed_node_min_capacity

      instance_types = var.managed_node_instance_types

      #launch templates only used to add name tags to managed nodes
      launch_template_id      = aws_launch_template.nodegroup1.id
      launch_template_version = aws_launch_template.nodegroup1.default_version

      # labels = {
      #     Name = "${local.cluster_name}-managed-node"
      # }      
      capacity_type  = var.managed_node_capacity_type

      k8s_labels = {
        Example    = "managed_node_groups"
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }


      additional_tags = {
        ExtraTag = "example"
      }

      update_config = {
        max_unavailable_percentage = 20 # or set `max_unavailable`
      }
    }
  }


    # Fargate Profile(s)
 fargate_profiles = {
    default = {
      name = "your-alb-sample-app"
      selectors = [
        {
          namespace = "game-2048"
        }
      ]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }



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

#enable cloudwatch logs using fluentbit helm chart to publish to cloudwatch log group
# module "cloudwatch_logs" {
#   source = "git::https://github.com/DNXLabs/terraform-aws-eks-cloudwatch-logs.git"

#   enabled = true

#   cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
#   cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
#   cluster_name                     = module.eks.cluster_id
#   worker_iam_role_name             = module.eks.worker_iam_role_name
#   region                           = var.region
#   helm_chart_version               = "0.1.7"

#   # Repo https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit
# }


