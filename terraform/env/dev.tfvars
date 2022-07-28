region = "us-west-1"
environment ="dev"
application_name = "Word-press"
service_list = ["app", "flask-api"]
node_instance_type ="t2.small"
minimum_nodes = 2
desired_nodes = 2
maximum_nodes = 7
admin_access_role_name = "administrator_role"
read_access_role_name = "developer_role"

datadog_secret_manager_arn = "arn:aws:secretsmanager:us-west-1:488144151286:secret:datadog_secret-NfzyMs"
datadog_namespace = "data-dog"

# Additions for existing vpc
vpc_id = "vpc-0668cebb4183634a6"

#ensure cidrs are approved by cloud team or devsecops before using
public_subnets_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
private_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]