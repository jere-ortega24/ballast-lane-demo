terraform {
  backend "s3" {
    bucket = "jere-demo-api"
    key    = "eks/service-accounts/iam/ebs-csi-driver"
    region = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      environment = "demo"
      managed-by  = "terraform"
    }
  }
}
