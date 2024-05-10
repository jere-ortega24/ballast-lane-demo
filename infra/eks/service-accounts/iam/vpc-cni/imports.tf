data "aws_region" "this" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "jere-demo-api"
    key    = "vpc"
    region = "us-west-2"
  }
}
