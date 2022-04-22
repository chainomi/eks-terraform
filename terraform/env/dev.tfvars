region = "us-west-1"
environment ="dev"
application_name = "dl-frame"
service_list = ["app"] #names of services to be run in the cluster. This is required to create repo's
node_instance_type ="t2.small" #change instance size to match service requirements
minimum_nodes = 2
desired_nodes = 2
maximum_nodes = 4

#Use this to allow AWS users view kubernetes cluster objects from the AWS console
#Note on role arns - Remove - "/aws-reserved/sso.amazonaws.com" from single sign on (SSO) roles
admin_access_role_arn = "arn:aws:iam::116591313158:role/AWSReservedSSO_AWSAdministratorAccess_6e9a3bfbd1f41b5e"
read_access_role_arn = "arn:aws:iam::116591313158:role/AWSReservedSSO_AWSReadOnlyAccess_11ff94d33034f4d0"
