# trigger CI
terraform {
  backend "s3" {
    bucket = "jere-demo-api"
    key    = "vpc"
    region = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48"
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
