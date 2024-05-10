locals {
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  eks_subnet_ids = concat(
    data.terraform_remote_state.vpc.outputs.private_subnet_ids,
    data.terraform_remote_state.vpc.outputs.public_subnet_ids
  )
  shared_tags = {
    environment = "demo"
    managed-by  = "eks"
  }
  addon_config = {
    aws_ebs_csi_driver = {
      controller = {
        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key      = "environment"
                      operator = "In"
                      values   = ["infrastructure"]
                    }
                  ]
                }
              ]
            }
          }
        }
        extraVolumeTags = local.shared_tags
        loggingFormat   = "json"
        volumeModificationFeature = {
          enabled = true
        }
      }
      node = {
        loggingFormat = "json"
      }
    }
    coredns = {
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "environment"
                    operator = "In"
                    values   = ["infrastructure"]
                  }
                ]
              }
            ]
          }
        }
      }
      podDisruptionBudget = {
        enabled        = true
        maxUnavailable = 1
      }
      topologySpreadConstraints = [
        {
          maxSkew           = 1
          topologyKey       = "topology.kubernetes.io/zone"
          whenUnsatisfiable = "ScheduleAnyway"
          labelSelector = {
            matchLabels = {
              "eks.amazonaws.com/component" = "coredns"
            }
          }
        },
      ]
    }
    eks_pod_identity_agent = {
      priorityClassName = "system-cluster-critical"
    }
    kube_proxy = {}
    vpc_cni = {
      env = {
        ADDITIONAL_ENI_TAGS = jsonencode(merge(
          {
            Name = var.cluster_name
          },
          local.shared_tags
        ))
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 365
}

resource "aws_eks_cluster" "this" {
  depends_on = [aws_cloudwatch_log_group.this]

  name = var.cluster_name
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  role_arn = data.terraform_remote_state.cluster_iam.outputs.iam_role_arn
  version  = var.kubernetes_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.100.0.0/16"
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    security_group_ids      = [aws_security_group.k8s.id]
    subnet_ids              = local.eks_subnet_ids
  }
}

resource "aws_eks_access_entry" "admin" {
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = var.admin_user_arn
  kubernetes_groups = []
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin.principal_arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = var.aws_ebs_csi_driver_version
  cluster_name                = aws_eks_cluster.this.name
  configuration_values        = jsonencode(local.addon_config.aws_ebs_csi_driver)
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
  service_account_role_arn    = data.terraform_remote_state.ebs_csi_driver_iam.outputs.iam_role_arn
}

resource "aws_eks_addon" "coredns" {
  addon_name                  = "coredns"
  addon_version               = var.coredns_version
  cluster_name                = aws_eks_cluster.this.name
  configuration_values        = jsonencode(local.addon_config.coredns)
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
}

resource "aws_eks_addon" "kube_proxy" {
  addon_name                  = "kube-proxy"
  addon_version               = var.kube_proxy_version
  cluster_name                = aws_eks_cluster.this.name
  configuration_values        = jsonencode(local.addon_config.kube_proxy)
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = var.eks_pod_identity_agent_version
  cluster_name                = aws_eks_cluster.this.name
  configuration_values        = jsonencode(local.addon_config.eks_pod_identity_agent)
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
}

resource "aws_eks_addon" "vpc_cni" {
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  cluster_name                = aws_eks_cluster.this.name
  configuration_values        = jsonencode(local.addon_config.vpc_cni)
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "NONE"
  service_account_role_arn    = data.terraform_remote_state.vpc_cni_iam.outputs.iam_role_arn
}

resource "random_string" "infrastructure" {
  length  = 4
  special = false
  upper   = false
}

resource "random_string" "demo" {
  length  = 4
  special = false
  upper   = false
}
