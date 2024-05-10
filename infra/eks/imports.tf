data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "vpc"
    region = "us-west-2"
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.terraform_remote_state.vpc.outputs.public_subnet_ids)

  id = each.value
}

data "aws_subnet" "private" {
  for_each = toset(data.terraform_remote_state.vpc.outputs.private_subnet_ids)

  id = each.value
}

data "terraform_remote_state" "cluster_iam" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "eks/service-accounts/iam/cluster"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "ebs_csi_driver_iam" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "eks/service-accounts/iam/ebs-csi-driver"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "node_iam" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "eks/service-accounts/iam/node"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "vpc_cni_iam" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "eks/service-accounts/iam/vpc-cni"
    region = "us-west-2"
  }
}


data "terraform_remote_state" "demo_api_iam" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "api/iam"
    region = "us-west-2"
  }
}
