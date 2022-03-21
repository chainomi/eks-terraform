variable "region" {
  description = "AWS region"
}

variable "application_name" {
    description = "Name of application e.g. DL Frame"
}

variable "environment" {
    description = "Name of environment e.g. dev, qa, prod"
}

variable "node_instance_type" {
    description = "type of nodes for eks cluster e.g. t2.small, m4.large,"
}
variable "desired_nodes" {
    description = "desired number of worker nodes"
}

variable "minimum_nodes" {
    description = "minimum number of worker nodes"
}

variable "maximum_nodes" {
    description = "maximum number of worker nodes"
}

# variable "admin_access_role_name"{
#     description = "the name of the admin role in AWS, this will map the Admin role to the cluster role xxxx .."
# }

variable "read_access_role_name"{
    description = "the name of the IAM role you wish to assign read access to in the eks cluster"
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether access roles for cluster is enabled."
}

