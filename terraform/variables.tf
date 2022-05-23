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

variable "admin_access_role_name"{
    description = "the name of the admin role in AWS, this will map the Admin role to the cluster role xxxx .."
}

variable "read_access_role_name"{
    description = "the name of the IAM role you wish to assign read access to in the eks cluster"
}

variable "rbac_enabled" {
  type        = bool
  default     = true
  description = "Used to enable or disable access roles for cluster"
}

variable "service_list" {
    description = "List of services or applications run in the cluster, this is required to build ecr repos"
}


# Datadog variables

variable "datadog_enabled" {
  type        = bool
  default     = false
  description = "Used to enable or disable access roles for cluster"
}

# variable "datadog_api_key" {
#   type = string
#   description = "Datadog API Key"
# }

# variable "datadog_app_key" {
#   type = string
#   description = "Datadog Application Key"
# }

variable "datadog_namespace" {
  type = string
  description = "namespace to install datadog agent on kubernetes"
}

variable "datadog_secret_manager_arn" {
  type = string
  description = "arn of datadog secrets (api and app keys) in secrets manager"
}
