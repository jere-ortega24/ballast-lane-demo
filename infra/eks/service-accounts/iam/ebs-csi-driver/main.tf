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
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = ["ec2:CreateTags"]
    effect  = "Allow"
    resources = [
      "arn:aws:ec2:*:*:snapshot/*",
      "arn:aws:ec2:*:*:volume/*",
    ]

    condition {
      test = "StringEquals"
      values = [
        "CreateSnapshot",
        "CreateVolume",
      ]
      variable = "ec2:CreateAction"
    }
  }

  statement {
    actions = ["ec2:DeleteTags"]
    effect  = "Allow"
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*",
    ]
  }

  statement {
    actions   = ["ec2:CreateVolume"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
    }
  }

  statement {
    actions   = ["ec2:CreateVolume"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "aws:RequestTag/CSIVolumeName"
    }
  }

  statement {
    actions   = ["ec2:DeleteVolume"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
    }
  }

  statement {
    actions   = ["ec2:DeleteVolume"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "ec2:ResourceTag/CSIVolumeName"
    }
  }

  statement {
    actions   = ["ec2:DeleteVolume"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "ec2:ResourceTag/kubernetes.io/created-for/pvc/name"
    }
  }

  statement {
    actions   = ["ec2:DeleteSnapshot"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["*"]
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
    }
  }

  statement {
    actions   = ["ec2:DeleteSnapshot"]
    effect    = "Allow"
    resources = ["*"]

    condition {
      test     = "StringLike"
      values   = ["true"]
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = "ebs-csi-driver-${var.environment}-${random_string.this.id}"
}

resource "aws_iam_role_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}
