
# Creates Kubernetes read cluster role and role binding in kubernetes cluster

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
