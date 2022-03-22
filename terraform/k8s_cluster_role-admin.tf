
# Kubernetes admin cluster role IAM policy and attachment

resource "aws_iam_policy" "admin-clusterRole-policy" {
  name        = "eks-admin-cluster-role-policy"
  description = "IAM eks admin cluster role policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:AccessKubernetesApi",
                "ssm:GetParameter",
                "eks:ListUpdates",
                "eks:ListFargateProfiles"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


data "aws_iam_role" "eks_admin_ClusterRole" {
  name = var.admin_access_role_name # gets name from existing admin access role in AWS IAM

}


resource "aws_iam_policy_attachment" "eks_admin_ClusterRole_attachment" {
  name       = "eks_admin_ClusterRole-attachment"
  roles      = [data.aws_iam_role.eks_admin_ClusterRole.name]

  policy_arn = aws_iam_policy.admin-clusterRole-policy.arn
}




# Creates Kubernetes cluster roles
resource "kubectl_manifest" "admin_ClusterRole" {
    count = var.rbac_enabled ? 1 : 0
    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: admin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
YAML
  
}

resource "kubectl_manifest" "admin_ClusterRoleBinding" {
    count = var.rbac_enabled ? 1 : 0
    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin
subjects:
- kind: Group
  name: admin
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
YAML

}
