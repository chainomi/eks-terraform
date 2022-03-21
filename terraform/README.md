# Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster), containing
Terraform configuration files to provision an EKS cluster on AWS.


## 1. Terraform - build infrastructure

### Build EKS cluster, Networking and ECR
a. `cd terraform/`
b. `terraform init`
c. `terraform plan -var-file=env/dev.tfvars`
d. `terraform apply -var-file=env/dev.tfvars --auto-approve`

### Add k8s cluster roles for EKS cluster
 This cannot be deployed with the cluster and needs to be done seperately. By default the k8s cluster roles resources are disabled. They have to be enabled using command below for subsequent terraform apply commands.
e. `terraform apply -var rbac_enabled=true -var-file=env/dev.tfvars`

## 2. Docker - build image
    a. `docker build -t app ../app/`

## 3. ECR - push image to ECR
a. login to ECR - `aws ecr get-login-password --region $(terraform output -raw region) | docker login --username AWS --password-stdin $(terraform output -raw aws_account_id).dkr.ecr.$(terraform output -raw region).amazonaws.com`
b. Tag image for ECR - `docker tag app:latest $(terraform output -raw ecr_url):latest`
c. Push image to ECR - `docker push $(terraform output -raw ecr_url):latest`

## 4. Deploy app to EKS cluster
a. Change kubeconfig context to eks cluster - `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
b. create kubernetes resources - `kubectl apply -f ../app/k8s/`
c. kubectl get all resources in default namespace - `kubectl get all -o wide`
d. watch events - `kubectl get events --watch`
e. get log for pod - `kubectl logs <pod_name>`
d. view ingress (app hostname and load balancer) - `kubectl get ingress -o wide`
d. view cluster roles - `kubectl get clusterroles`
f. View cluster roles mapped to iam role - `kubectl edit configmap/aws-auth -n kube-system`

## 5. Map load balancer to ingress hostname in Route 53
a. The load balancer created by the ingress resources has to be manually added to the hostname record in Route 53 


ECR commands

login
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 488144151286.dkr.ecr.us-west-1.amazonaws.com
docker tag app_app:latest 488144151286.dkr.ecr.us-west-1.amazonaws.com/app:latest
docker push 488144151286.dkr.ecr.us-west-1.amazonaws.com/app:latest

