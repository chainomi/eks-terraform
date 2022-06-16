# Instructions to deploy pod with kubectl 
Followed the link below but used the bitnami kubectl docker image and passed in kubectl proxy commands using the pod manifest

https://medium.com/@barnie_M/accessing-kubernetes-api-from-a-pod-using-kubectl-proxy-sidecar-fbb85781969f

The Dockerfile in this folder can be used to build a custom image

You need to create a cluster role binding for the default service account to the cluster-admin role or create a cluster role with access to the api, without that you cant access the api server. see RBAC 

Run from Terraform folder `kubectl apply -f ../app_kubeproxy_sidecar/ci/k8s/`

kubernetes binaries https://www.downloadkubernetes.com/
