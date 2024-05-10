resource "aws_launch_template" "infrastructure" {
  name                    = "eks-${aws_eks_cluster.this.name}-${var.node_group_infrastructure.name}-${random_string.infrastructure.id}"
  disable_api_stop        = true
  disable_api_termination = true
  ebs_optimized           = true
  update_default_version  = true
  vpc_security_group_ids = [
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id,
    aws_security_group.k8s.id,
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "eks-${aws_eks_cluster.this.name}-${var.node_group_infrastructure.name}-${random_string.infrastructure.id}"
      },
      local.shared_tags
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "eks-${aws_eks_cluster.this.name}-${var.node_group_infrastructure.name}-${random_string.infrastructure.id}"
      },
      local.shared_tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "demo" {
  name                    = "eks-${aws_eks_cluster.this.name}-${var.node_group_demo.name}-${random_string.demo.id}"
  disable_api_stop        = true
  disable_api_termination = true
  ebs_optimized           = true
  update_default_version  = true
  vpc_security_group_ids = [
    aws_eks_cluster.this.vpc_config[0].cluster_security_group_id,
    aws_security_group.k8s.id,
  ]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "eks-${aws_eks_cluster.this.name}-${var.node_group_demo.name}-${random_string.demo.id}"
      },
      local.shared_tags
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "eks-${aws_eks_cluster.this.name}-${var.node_group_demo.name}-${random_string.demo.id}"
      },
      local.shared_tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}
