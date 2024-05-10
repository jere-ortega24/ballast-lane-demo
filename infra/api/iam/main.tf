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
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = "demo-api-${var.environment}-${random_string.this.id}"
}

resource "aws_iam_role_policy" "this" {
  policy = data.aws_iam_policy_document.this.json
  role   = aws_iam_role.this.id
}
