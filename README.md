# Terraform EKS cluster

Use the code in the repo to provision an EKS cluster with Terraform. It also includes a sample containerized python application (quote of the day) and manifest files for deployment on the created EKS cluster.

## Features of EKS cluster
The add-ons to the eks cluster were installed using the Terraform helm provider
1. AWS load balancer controller
2. Cluster autoscaler
3. Horizontal Pod scaler and metrics server
4. Prometheus and Grafana monitoring


## Setup
### k8s
1. Enter ingress annotations for dns hostname and certificate arn if applicable in `./app/ci/k8s/ingress.yml`
2. Update image repo accordingly in `./app/ci/k8s/app-manifest.yml`
### Terraform
1. Enter environment values for cluster in tfvar files found in `./terraform/env`

## Terraform - build infrastructure

### Build EKS cluster, Networking and ECR
1. `cd terraform/`
2. `terraform init`
3. `terraform plan -var-file=env/<env>.tfvars`
4. `terraform apply -var-file=env/<env>.tfvars --auto-approve`

## Docker - build image
1. `docker build -t app ../app/`

## ECR - push image to ECR
1. login to ECR - `aws ecr get-login-password --region $(terraform output -raw region) | docker login --username AWS --password-stdin $(terraform output -raw aws_account_id).dkr.ecr.$(terraform output -raw region).amazonaws.com`
2. Tag image for ECR - `docker tag app:latest $(terraform output -json repository_url_map | jq -r '.app'):latest`
3. Push image to ECR - `docker push $(terraform output -json repository_url_map | jq -r '.app'):latest`

## Deploy app to EKS cluster
1. Change kubeconfig context to eks cluster - `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
2. create kubernetes resources - `kubectl apply -f ../app/ci/k8s/`
3. kubectl get all resources in default namespace - `kubectl get all -o wide`
4. watch events - `kubectl get events --watch`
5. get log for pod - `kubectl logs <pod_name>`
6. view ingress (app hostname and load balancer) - `kubectl get ingress -o wide`
7. view cluster roles - `kubectl get clusterroles`
8. View cluster roles mapped to iam role - `kubectl edit configmap/aws-auth -n kube-system`

Fargate
kubectl create namespace fargate-test
kubectl apply -f ../app/ci/k8s/ -n fargate-test
## Deploy app with Helm chart
1. Create chart - `cd` into folder you want chat on and enter - 
`Test template to ensure its working - helm template app_chart --values ./app_chart/values-dev.yaml`
2. `Install - helm install app-chart1 ../app/ci/app_chart/ --values ../app/ci/app_chart/values-dev.yaml`
3. `Dry run - helm install app-chart1 ../app/ci/app_chart/ --values ../app/ci/app_chart/values-dev.yaml --dry-run`
4. `view installed charts - helm list`

## Open app 
1. Open the hostname entered in the app's ingress manifest or load balancer address if no hostname is specified in the ingress manifest `<hostname>/qod` or `<load balancer dns address>/qod`


## References
1. [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster)

