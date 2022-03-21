
# Kubernetes cluster role IAM policy and attachment

resource "aws_iam_policy" "clusterRole-policy" {
  name        = "eks-cluster-role-policy"
  description = "IAM cluster role policy"

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


data "aws_iam_role" "eks_ClusterRole" {
  name = var.read_access_role_name # gets name from existing read access role in AWS IAM

}


resource "aws_iam_policy_attachment" "eks_ClusterRole_attachment" {
  name       = "eks_ClusterRole-attachment"
  roles      = [data.aws_iam_role.eks_ClusterRole.name]
  # roles      = [var.aws_iam_role_arn]

  policy_arn = aws_iam_policy.clusterRole-policy.arn
}




# Creates Kubernetes cluster roles
resource "kubectl_manifest" "reader_ClusterRole" {
    count = var.rbac_enabled ? 1 : 0
    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: reader
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
YAML
  
}

resource "kubectl_manifest" "reader_ClusterRoleBinding" {
    count = var.rbac_enabled ? 1 : 0
    yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: reader
subjects:
- kind: Group
  name: reader
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: reader
  apiGroup: rbac.authorization.k8s.io
YAML

}
