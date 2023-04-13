region = "us-west-1"
environment ="dev"
application_name = "Word-press"
service_list = ["app", "flask-api"]

# Self managed node configuration
node_instance_type ="t2.small"
minimum_nodes = 2
desired_nodes = 10
maximum_nodes = 2

# AWS managed nodes configuration
managed_node_group_name = "node-group-1"
managed_node_instance_types = ["t2.small"]
managed_node_capacity_type = "SPOT" #choose between "SPOT" and "ON-DEMAND"
managed_node_desired_capacity = 2
managed_node_max_capacity     = 10
managed_node_min_capacity     = 2

admin_access_role_name = "administrator_role"
read_access_role_name = "developer_role"

datadog_secret_manager_arn = "arn:aws:secretsmanager:us-west-1:488144151286:secret:datadog_secret-NfzyMs"
datadog_namespace = "data-dog"



