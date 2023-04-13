resource "aws_launch_template" "nodegroup1" {
  name_prefix            = "${local.cluster_name}-"
  description            = "${local.cluster_name} managed ${var.managed_node_group_name} Launch-Template"
  update_default_version = true


  # Supplying custom tags to EKS instances is another use-case for LaunchTemplates
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.cluster_name}-managed-${var.managed_node_group_name}"
    }
  }


  lifecycle {
    create_before_destroy = true
  }
}