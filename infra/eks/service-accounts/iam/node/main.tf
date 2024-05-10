resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
}

data "aws_iam_policy_document" "assume" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = "eks-node-${var.environment}-${random_string.this.id}"
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_ro" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
