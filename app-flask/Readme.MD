python3 -m venv env
source env/bin/activate
which python

pip install -r requirements.txt

python3 app_<env>.yml




## Cloud deployment (AWS EKS)

## Docker image build
1. `docker build -t flask-api ../app-flask/`

## ECR - push image to ECR (from Terraform folder)
1. login to ECR - `aws ecr get-login-password --region $(terraform output -raw region) | docker login --username AWS --password-stdin $(terraform output -raw aws_account_id).dkr.ecr.$(terraform output -raw region).amazonaws.com`
2. Tag image for ECR - `docker tag flask-api:latest $(terraform output -json repository_url_map | jq -r '."flask-api"'):latest`
3. Push image to ECR - `docker push $(terraform output -json repository_url_map | jq -r '."flask-api"'):latest`

## Deploy app to EKS cluster (from Terraform folder)
1. Change kubeconfig context to eks cluster - `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)`
2. create kubernetes resources - `kubectl apply -f ../app-flask/ci/k8s/`


## Testing

### Create resources
1. Deploy and create flask api in kubernetes cluster - 
2. For demo we will create an nginx deployment 

### create and update config map
1. create config map with values in json payload.
        ```
        curl --location --request POST 'https://hostname/create_map' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "configmap_name" : "test-configmap",
            "redis_host" : "redux_1234.com",
            "redis_port" : "8080"
        }'
       ```
2. update config map with values in json payload.
        ```
        curl --location --request POST 'https://hostname/create_map' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "configmap_name" : "test-configmap",
            "redis_host" : "redux_1235.com",
            "redis_port" : "8084"
        }'
       ```

### Update and restart deployment
1. update config map and restart a deployment with configmap
        ```
        curl --location --request POST 'https://hostname/update_map_restart_deployment' \
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