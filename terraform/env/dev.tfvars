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
