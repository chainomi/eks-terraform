# Flask app using Kubernetes client library for Python

## Introduction
This application was written to show how kubernetes resources can be created and updated programmatically using the kubernetes client library in python. For demo purposes the application uses a flask webserver, which recieves a json payload to trigger python functions using the kubernetes library which communicates with the kubernetes API on a cluster for resource creation and updates. 


## Requirements
1. AWS CLI
2. Kubectl
3. Python
4. Pip
5. Docker


## Instructions

## Running application locally

### Kube config setup
The application will require access to an kubernetes (EKS) cluster where resources will be deployed and updated. Access to EKS cluster is typically granted using the aws cli and the kubeconfig file. 

1. Ensure kubectl is installed on machine.
2. Update kubeconfig context to EKS cluster where resources will be deployed and updated using command - `aws eks --region <aws_region> update-kubeconfig --name <cluster_name>`

### Starting application 
Use the following commands to run the application using python

> 1. Setup virtual environment - `python3 -m venv env`
> 2. Activate virtual environment in env folder - `source env/bin/activate`
> 3. Check python version and folder where dependencies will be run from - `which python`
> 4. Install dependencies - `pip install -r requirements.txt`
> 5. Run application - `python3 app_flask_api.py`
> 6. Confirm application is running `http://localhost:8000/`


## Running application in the cloud (AWS)

## Cloud deployment (AWS EKS)

### Docker image build
1. `docker build -t flask-api .`

### ECR - push image to ECR (from Terraform folder)
1. Create repo in AWS ECR named `flask-api`.
2. login to ECR - `aws ecr get-login-password --region <aws_region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com`
3. Tag image for ECR - `docker tag flask-api:latest <aws_ecr_repository_url>:latest`
4. Push image to ECR - `docker push <aws_ecr_repository_url>:latest`

## Updating manifest files
1. Update hostname in `ci/k8s/ingress.yml` to the desired hostname.
2. Update the SSL certificate for domain in `ci/k8s/ingress.yml`.
3. Update the container image in the `ci/k8s/app-manifest.yml` file to the ECR image URL.
   

### Deploy app to EKS cluster 
1. Change kubeconfig context to eks cluster - `aws eks --region <aws_region> update-kubeconfig --name <cluster_name>`
2. create kubernetes resources - `kubectl apply -f ci/k8s/`


## Testing
Perform the following below to test the application locally and in the cloud.

### Notes
1. Local testing (using python file) - replace <hostname> with localhost.
2. Cloud testing (using deployed containerized app) - replace <hostname> with cloud hostname.
3. For demo we will create an nginx deployment 

### Create and update config map
1. Create config map with values in json payload.
   
        ```
        curl --location --request POST 'https://<hostname>/create_map' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "configmap_name" : "test-configmap",
            "redis_host" : "redux_1234.com",
            "redis_port" : "8080"
        }'
        ```
    
2. Update config map with values in json payload.
   
        ```
        curl --location --request POST 'https://<hostname>/create_map' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "configmap_name" : "test-configmap",
            "redis_host" : "redux_1235.com",
            "redis_port" : "8084"
        }'
        ```

### Update and restart deployment
1. Update config map and restart a deployment with configmap
   
        ```
        curl --location --request POST 'https://<hostname>/update_map_restart_deployment' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "deployment_name" : "nginx-deployment",
            "configmap_name" : "test-configmap",
            "redis_host" : "redux_1236.com",
            "redis_port" : "8085"
        }'
        ```


## References
https://www.digitalocean.com/community/tutorials/processing-incoming-request-data-in-flask

https://www.geeksforgeeks.org/how-to-return-a-json-object-from-a-python-function/

https://github.com/kubernetes-client/python/blob/768f520c676efe1b44556aea76d4f38533becc25/examples/dynamic-client/configmap.py


https://www.codegrepper.com/code-examples/python/change+port+flask

https://onlineyamltools.com/convert-yaml-to-json

dynamically switching between incluster and kube config when running client
https://blog.mikesir87.io/2020/04/creating-kubernetes-monitor-with-blinksticks/