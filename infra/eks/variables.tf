variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "aws_ebs_csi_driver_version" {
  type = string
}

variable "coredns_version" {
  type = string
}

variable "eks_pod_identity_agent_version" {
  type = string
}

variable "kube_proxy_version" {
  type = string
}

variable "vpc_cni_version" {
  type = string
}

variable "admin_user_arn" {
  type = string
}

variable "node_group_infrastructure" {
  type = object({
    name            = string,
    instance_types  = list(string),
    labels          = map(string),
    release_version = string,
    scaling_config = object({
      desired_size = number,
      min_size     = number,
      max_size     = number
    })
    version = string
  })
}

variable "node_group_demo" {
  type = object({
    name            = string,
    instance_types  = list(string)
    labels          = map(string)
    release_version = string,
    scaling_config = object({
      desired_size = number,
      min_size     = number,
      max_size     = number
    })
    version = string
  })
}
