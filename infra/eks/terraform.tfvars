cluster_name                   = "demo"
kubernetes_version             = "1.29"
aws_ebs_csi_driver_version     = "v1.30.0-eksbuild.1"
coredns_version                = "v1.11.1-eksbuild.4"
eks_pod_identity_agent_version = "v1.2.0-eksbuild.1"
kube_proxy_version             = "v1.29.0-eksbuild.1"
vpc_cni_version                = "v1.18.1-eksbuild.1"
admin_user_arn                 = "arn:aws:iam::652725896823:user/jere"

node_group_infrastructure = {
  instance_types = ["t3.medium"]
  labels = {
    "environment" = "infrastructure"
  }
  name            = "infrastructure"
  release_version = "1.29.0-20240415"
  scaling_config = {
    desired_size = 2
    max_size     = 2
    min_size     = 0
  }
  version = "1.29"
}

node_group_demo = {
  instance_types = ["t3.medium"]
  labels = {
    "environment" = "demo"
  }
  name            = "demo"
  release_version = "1.29.0-20240415"
  scaling_config = {
    desired_size = 2
    max_size     = 2
    min_size     = 0
  }
  version = "1.29"
}
