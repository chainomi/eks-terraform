
# Creates Kubernetes admin cluster role and role binding in kubernetes cluster

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
