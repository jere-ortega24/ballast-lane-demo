resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
}

data "aws_iam_policy_document" "assume" {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    effect = "Allow"

    principals {
      identifiers = ["pods.eks.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "this" {
  version = "2012-10-17"

  statement {
    actions = [
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions   = ["ec2:CreateTags"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:network-interface/*"]
  }

  statement {
    actions   = ["ec2:CreateNetworkInterface"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:network-interface/*"]

    condition {
      test     = "StringEquals"
      values   = [var.cluster_name]
      variable = "aws:RequestTag/cluster.k8s.amazonaws.com/name"
    }
  }

  statement {
    actions = ["ec2:CreateNetworkInterface"]
    effect  = "Allow"
    resources = [
      "arn:aws:ec2:${data.aws_region.this.name}:*:security-group/*",
      "arn:aws:ec2:${data.aws_region.this.name}:*:subnet/*",
    ]

    condition {
      test     = "ArnEquals"
      values   = ["arn:aws:ec2:${data.aws_region.this.name}:*:vpc/${data.terraform_remote_state.vpc.outputs.vpc_id}"]
      variable = "ec2:Vpc"
    }
  }

  statement {
    actions = [
      "ec2:AssignPrivateIpAddresses",
      "ec2:AttachNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:UnassignPrivateIpAddresses",
    ]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:network-interface/*"]

    condition {
      test     = "StringEquals"
      values   = [var.cluster_name]
      variable = "aws:ResourceTag/cluster.k8s.amazonaws.com/name"
    }
  }
  statement {
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
    ]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:instance/*"]

    condition {
      test     = "StringEquals"
      values   = ["owned"]
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
    }
  }

  statement {
    actions   = ["ec2:ModifyNetworkInterfaceAttribute"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:security-group/*"]
  }

  statement {
    actions   = ["ec2:ModifyNetworkInterfaceAttribute"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:${data.aws_region.this.name}:*:network-interface/*"]

    condition {
      test     = "ArnEquals"
      values   = ["arn:aws:ec2:${data.aws_region.this.name}:*:vpc/${data.terraform_remote_state.vpc.outputs.vpc_id}"]
      variable = "ec2:Vpc"
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = "vpc-cni-sa-${var.environment}-${random_string.this.id}"
}

resource "aws_iam_role_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}
