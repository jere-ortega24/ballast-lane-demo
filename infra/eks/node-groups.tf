resource "aws_eks_node_group" "infrastructure" {
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  cluster_name    = aws_eks_cluster.this.name
  instance_types  = var.node_group_infrastructure.instance_types
  labels          = var.node_group_infrastructure.labels
  node_group_name = "${var.node_group_infrastructure.name}-${random_string.infrastructure.id}"
  node_role_arn   = data.terraform_remote_state.node_iam.outputs.iam_role_arn
  release_version = var.node_group_infrastructure.release_version
  subnet_ids      = local.private_subnet_ids
  version         = var.node_group_infrastructure.version

  launch_template {
    id      = aws_launch_template.infrastructure.id
    version = aws_launch_template.infrastructure.latest_version
  }

  scaling_config {
    desired_size = var.node_group_infrastructure.scaling_config.desired_size
    max_size     = var.node_group_infrastructure.scaling_config.max_size
    min_size     = var.node_group_infrastructure.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    create_before_destroy = true
    #     ignore_changes        = [scaling_config[0].desired_size]
  }
}

resource "aws_eks_node_group" "demo" {
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  cluster_name    = aws_eks_cluster.this.name
  instance_types  = var.node_group_demo.instance_types
  labels          = var.node_group_demo.labels
  node_group_name = "${var.node_group_demo.name}-${random_string.demo.id}"
  node_role_arn   = data.terraform_remote_state.node_iam.outputs.iam_role_arn
  release_version = var.node_group_demo.release_version
  subnet_ids      = local.private_subnet_ids
  version         = var.node_group_demo.version

  launch_template {
    id      = aws_launch_template.demo.id
    version = aws_launch_template.demo.latest_version
  }

  scaling_config {
    desired_size = var.node_group_demo.scaling_config.desired_size
    max_size     = var.node_group_demo.scaling_config.max_size
    min_size     = var.node_group_demo.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    create_before_destroy = true
    #     ignore_changes        = [scaling_config[0].desired_size]
  }
}
